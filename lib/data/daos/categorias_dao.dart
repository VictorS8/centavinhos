import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../database.dart';
import 'cadastro_bloqueado.dart';

/// Uma categoria e se ela já foi usada num lançamento.
typedef CategoriaComUso = ({Categoria categoria, bool emUso});

/// Uma categoria principal com as subcategorias dela.
class CategoriaComSubcategorias {
  const CategoriaComSubcategorias(this.principal, this.subcategorias);

  final CategoriaComUso principal;
  final List<CategoriaComUso> subcategorias;

  Categoria get categoria => principal.categoria;

  /// Se ela ou alguma subcategoria foi usada: aí ela só pode ser arquivada.
  bool get emUso => principal.emUso || subcategorias.any((s) => s.emUso);

  /// Organiza [todas] em categorias principais com as subcategorias, cada
  /// nível com as ativas primeiro e em ordem de nome.
  static List<CategoriaComSubcategorias> montar(Iterable<CategoriaComUso> todas) {
    int ordem(CategoriaComUso a, CategoriaComUso b) =>
        a.categoria.arquivada != b.categoria.arquivada
        ? a.categoria.arquivada.compareTo(b.categoria.arquivada)
        : chaveDoNome(a.categoria.nome).compareTo(chaveDoNome(b.categoria.nome));

    final principais = todas.where((c) => c.categoria.categoriaPaiId == null).toList()
      ..sort(ordem);
    return [
      for (final principal in principais)
        CategoriaComSubcategorias(
          principal,
          todas.where((c) => c.categoria.categoriaPaiId == principal.categoria.id).toList()
            ..sort(ordem),
        ),
    ];
  }
}

/// Categorias e subcategorias: criar, renomear, arquivar, desarquivar e
/// excluir. A subcategoria tem o tipo da principal e um nível só.
class CategoriasDao extends DatabaseAccessor<AppDatabase> {
  CategoriasDao(super.attachedDatabase);

  Categorias get _categorias => attachedDatabase.categorias;

  /// Todas as categorias, arquivadas ou não, com o uso de cada uma.
  Stream<List<CategoriaComUso>> observar() => customSelect(
    'SELECT c.*, EXISTS (SELECT 1 FROM lancamento_categorias '
    'WHERE categoria_id = c.id) AS em_uso FROM categorias c',
    readsFrom: {_categorias, attachedDatabase.lancamentoCategorias},
  ).watch().map(
    (linhas) => [
      for (final linha in linhas)
        (categoria: _categorias.map(linha.data), emUso: linha.read<bool>('em_uso')),
    ],
  );

  /// Se a categoria, ou alguma subcategoria dela, foi usada num lançamento.
  Future<bool> emUso(int id) => customSelect(
    'SELECT EXISTS (SELECT 1 FROM lancamento_categorias lc '
    'JOIN categorias c ON c.id = lc.categoria_id '
    'WHERE c.id = ?1 OR c.categoria_pai_id = ?1) AS em_uso',
    variables: [Variable.withInt(id)],
  ).map((linha) => linha.read<bool>('em_uso')).getSingle();

  Future<Categoria> _buscar(int id) =>
      (select(_categorias)..where((c) => c.id.equals(id))).getSingle();

  /// Cria uma categoria principal do [tipo] ('ganho' ou 'despesa').
  Future<int> criar({required String nome, required String tipo}) => into(_categorias).insert(
    CategoriasCompanion.insert(nome: limparNome(nome), tipo: tipo),
  );

  /// Cria uma subcategoria de [principalId], com o mesmo tipo dela.
  Future<int> criarSubcategoria({required String nome, required int principalId}) async {
    final principal = await _buscar(principalId);
    if (principal.categoriaPaiId != null) {
      throw ArgumentError.value(principalId, 'principalId', 'já é uma subcategoria');
    }
    return into(_categorias).insert(
      CategoriasCompanion.insert(
        nome: limparNome(nome),
        tipo: principal.tipo,
        categoriaPaiId: Value(principalId),
      ),
    );
  }

  Future<void> renomear(int id, String nome) => (update(_categorias)
        ..where((c) => c.id.equals(id)))
      .write(CategoriasCompanion(nome: Value(limparNome(nome))));

  /// Arquiva a categoria. Numa principal, as subcategorias vão junto.
  Future<void> arquivar(int id) => (update(_categorias)
        ..where((c) => c.id.equals(id) | c.categoriaPaiId.equals(id)))
      .write(const CategoriasCompanion(arquivada: Value(1)));

  /// Desarquiva a categoria. Numa principal, as subcategorias voltam junto;
  /// numa subcategoria com a principal arquivada, a principal volta também.
  Future<void> desarquivar(int id) => transaction(() async {
    final categoria = await _buscar(id);
    final paiId = categoria.categoriaPaiId;
    await (update(_categorias)..where(
          (c) => paiId == null
              ? c.id.equals(id) | c.categoriaPaiId.equals(id)
              : c.id.equals(id) | c.id.equals(paiId),
        ))
        .write(const CategoriasCompanion(arquivada: Value(0)));
  });

  /// Apaga de vez uma categoria que nunca foi usada. Numa principal, as
  /// subcategorias são apagadas junto, e nenhuma delas pode ter sido usada.
  Future<void> excluir(int id) => transaction(() async {
    if (await emUso(id)) {
      throw const CadastroBloqueado('Esta categoria já foi usada: ela só pode ser arquivada.');
    }
    await (delete(_categorias)..where((c) => c.categoriaPaiId.equals(id))).go();
    await (delete(_categorias)..where((c) => c.id.equals(id))).go();
  });
}
