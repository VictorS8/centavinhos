import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../database.dart';
import 'cadastro_bloqueado.dart';

/// Uma tag e em quantos lançamentos ela aparece.
typedef TagComUso = ({Tag tag, int lancamentos});

/// Tags: criar, renomear, arquivar, desarquivar e excluir.
class TagsDao extends DatabaseAccessor<AppDatabase> {
  TagsDao(super.attachedDatabase);

  Tags get _tags => attachedDatabase.tags;

  /// Todas as tags, as ativas primeiro, cada grupo em ordem de nome.
  Stream<List<TagComUso>> observar() => customSelect(
    'SELECT t.*, (SELECT COUNT(*) FROM lancamento_tags WHERE tag_id = t.id) '
    'AS lancamentos FROM tags t',
    readsFrom: {_tags, attachedDatabase.lancamentoTags},
  ).watch().map((linhas) {
    final tags = [
      for (final linha in linhas)
        (tag: _tags.map(linha.data), lancamentos: linha.read<int>('lancamentos')),
    ];
    return tags..sort(
      (a, b) => a.tag.arquivada != b.tag.arquivada
          ? a.tag.arquivada.compareTo(b.tag.arquivada)
          : chaveDoNome(a.tag.nome).compareTo(chaveDoNome(b.tag.nome)),
    );
  });

  Future<bool> emUso(int id) => customSelect(
    'SELECT EXISTS (SELECT 1 FROM lancamento_tags WHERE tag_id = ?) AS em_uso',
    variables: [Variable.withInt(id)],
  ).map((linha) => linha.read<bool>('em_uso')).getSingle();

  /// Cria a tag. O "#" do começo, das hashtags, sai do nome.
  Future<int> criar(String nome) =>
      into(_tags).insert(TagsCompanion.insert(nome: limparNomeTag(nome)));

  Future<void> renomear(int id, String nome) => (update(_tags)
        ..where((t) => t.id.equals(id)))
      .write(TagsCompanion(nome: Value(limparNomeTag(nome))));

  Future<void> arquivar(int id) => _marcarArquivada(id, 1);

  Future<void> desarquivar(int id) => _marcarArquivada(id, 0);

  /// Apaga de vez uma tag que nunca foi usada.
  Future<void> excluir(int id) => transaction(() async {
    if (await emUso(id)) {
      throw const CadastroBloqueado('Esta tag já foi usada: ela só pode ser arquivada.');
    }
    await (delete(_tags)..where((t) => t.id.equals(id))).go();
  });

  Future<void> _marcarArquivada(int id, int valor) => (update(_tags)
        ..where((t) => t.id.equals(id)))
      .write(TagsCompanion(arquivada: Value(valor)));
}
