import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/daos/categorias_dao.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../widgets/acoes_cadastro.dart';
import '../../widgets/lista_cadastro.dart';
import 'janela_nome.dart';

/// Categorias de despesa ou de ganho, cada uma com as subcategorias.
class AbaCategorias extends ConsumerStatefulWidget {
  const AbaCategorias({super.key});

  @override
  ConsumerState<AbaCategorias> createState() => _AbaCategoriasState();
}

class _AbaCategoriasState extends ConsumerState<AbaCategorias> {
  var _tipo = 'despesa';
  var _mostrarArquivadas = false;

  CategoriasDao get _dao => ref.read(bancoProvider).categoriasDao;

  static Iterable<NomeExistente> _nomes(Iterable<CategoriaComUso> itens, {int? exceto}) => [
    for (final (:categoria, emUso: _) in itens)
      if (categoria.id != exceto) (nome: categoria.nome, arquivado: categoria.arquivada == 1),
  ];

  void _novaCategoria(List<CategoriaComSubcategorias> arvore) => abrirJanelaNome(
    context,
    titulo: 'Nova categoria de ${_tipo == 'despesa' ? 'despesa' : 'ganho'}',
    rotulo: 'Nome da categoria',
    tipo: Cadastro.categoria,
    existentes: _nomes(arvore.map((g) => g.principal)),
    aoSalvar: (nome) => _dao.criar(nome: nome, tipo: _tipo),
  );

  void _novaSubcategoria(CategoriaComSubcategorias grupo) => abrirJanelaNome(
    context,
    titulo: 'Nova subcategoria de ${grupo.categoria.nome}',
    rotulo: 'Nome da subcategoria',
    tipo: Cadastro.subcategoria,
    existentes: _nomes(grupo.subcategorias),
    aoSalvar: (nome) => _dao.criarSubcategoria(nome: nome, principalId: grupo.categoria.id),
  );

  void _renomear(Categoria categoria, Iterable<CategoriaComUso> irmas) {
    final tipo = categoria.categoriaPaiId == null ? Cadastro.categoria : Cadastro.subcategoria;
    abrirJanelaNome(
      context,
      titulo: 'Renomear ${tipo.nome}',
      rotulo: 'Nome da ${tipo.nome}',
      tipo: tipo,
      inicial: categoria.nome,
      existentes: _nomes(irmas, exceto: categoria.id),
      aoSalvar: (nome) => _dao.renomear(categoria.id, nome),
    );
  }

  void _tirar(Categoria categoria, {required bool emUso, int subcategorias = 0}) {
    final tipo = categoria.categoriaPaiId == null ? Cadastro.categoria : Cadastro.subcategoria;
    final String? extra;
    if (subcategorias == 0) {
      extra = null;
    } else if (emUso) {
      extra = 'As subcategorias dela são arquivadas junto.';
    } else {
      extra = subcategorias == 1
          ? 'A subcategoria dela também.'
          : 'As $subcategorias subcategorias dela também.';
    }
    tirarCadastro(
      context,
      tipo: tipo,
      nome: categoria.nome,
      emUso: emUso,
      extra: extra,
      excluir: () => _dao.excluir(categoria.id),
      arquivar: () => _dao.arquivar(categoria.id),
    );
  }

  void _desarquivar(Categoria categoria) => desarquivarCadastro(
    context,
    tipo: categoria.categoriaPaiId == null ? Cadastro.categoria : Cadastro.subcategoria,
    nome: categoria.nome,
    desarquivar: () => _dao.desarquivar(categoria.id),
  );

  @override
  Widget build(BuildContext context) {
    final todas = ref.watch(categoriasProvider).value ?? const [];
    final arvore = CategoriaComSubcategorias.montar(
      todas.where((c) => c.categoria.tipo == _tipo),
    );
    bool visivel(Categoria c) => _mostrarArquivadas || c.arquivada == 0;

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      children: [
        Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'despesa', label: Text('Despesas')),
                ButtonSegment(value: 'ganho', label: Text('Ganhos')),
              ],
              selected: {_tipo},
              onSelectionChanged: (selecao) => setState(() => _tipo = selecao.single),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () => _novaCategoria(arvore),
              icon: const Icon(Icons.add),
              label: const Text('Nova categoria'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListaCadastro(
          textoVazio: 'Nenhuma categoria.',
          linhas: [
            for (final grupo in arvore)
              if (visivel(grupo.categoria)) ...[
                _linhaPrincipal(grupo, arvore),
                for (final sub in grupo.subcategorias)
                  if (visivel(sub.categoria)) _linhaSubcategoria(sub, grupo),
              ],
          ],
        ),
        const SizedBox(height: 12),
        CaixaMostrarArquivados(
          rotulo: Cadastro.categoria.mostrarArquivados,
          valor: _mostrarArquivadas,
          onChanged: (valor) => setState(() => _mostrarArquivadas = valor),
        ),
      ],
    );
  }

  Widget _linhaPrincipal(CategoriaComSubcategorias grupo, List<CategoriaComSubcategorias> arvore) {
    final categoria = grupo.categoria;
    final arquivada = categoria.arquivada == 1;
    // Conta as subcategorias que aparecem logo abaixo.
    final visiveis = grupo.subcategorias
        .where((s) => _mostrarArquivadas || s.categoria.arquivada == 0)
        .length;
    return LinhaCadastro(
      key: ValueKey(categoria.id),
      marca: MarcaInicial(categoria.nome),
      nome: categoria.nome,
      destaque: true,
      detalhe: [textoSubcategorias(visiveis), if (arquivada) 'arquivada'].join(' · '),
      arquivado: arquivada,
      acoes: [
        if (!arquivada)
          IconButton(
            onPressed: () => _novaSubcategoria(grupo),
            tooltip: 'Nova subcategoria',
            icon: const Icon(Icons.add),
          ),
        ...botoesDeCadastro(
          arquivado: arquivada,
          emUso: grupo.emUso,
          rotuloEditar: 'Renomear',
          aoEditar: () => _renomear(categoria, arvore.map((g) => g.principal)),
          aoTirar: () => _tirar(
            categoria,
            emUso: grupo.emUso,
            subcategorias: grupo.subcategorias.length,
          ),
          aoDesarquivar: () => _desarquivar(categoria),
        ),
      ],
    );
  }

  Widget _linhaSubcategoria(CategoriaComUso sub, CategoriaComSubcategorias grupo) {
    final categoria = sub.categoria;
    final arquivada = categoria.arquivada == 1;
    return LinhaCadastro(
      key: ValueKey(categoria.id),
      marca: const MarcaPonto(),
      nome: categoria.nome,
      detalhe: arquivada ? 'arquivada' : null,
      recuo: true,
      arquivado: arquivada,
      acoes: botoesDeCadastro(
        arquivado: arquivada,
        emUso: sub.emUso,
        rotuloEditar: 'Renomear',
        aoEditar: () => _renomear(categoria, grupo.subcategorias),
        aoTirar: () => _tirar(categoria, emUso: sub.emUso),
        aoDesarquivar: () => _desarquivar(categoria),
      ),
    );
  }
}
