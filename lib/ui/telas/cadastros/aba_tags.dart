import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/daos/tags_dao.dart';
import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../widgets/acoes_cadastro.dart';
import '../../widgets/lista_cadastro.dart';
import 'janela_nome.dart';

/// Tags (as hashtags do Minhas Finanças), com quantos lançamentos usam cada
/// uma.
class AbaTags extends ConsumerStatefulWidget {
  const AbaTags({super.key});

  @override
  ConsumerState<AbaTags> createState() => _AbaTagsState();
}

class _AbaTagsState extends ConsumerState<AbaTags> {
  var _mostrarArquivadas = false;

  static Iterable<NomeExistente> _nomes(List<TagComUso> tags, {int? exceto}) => [
    for (final (:tag, lancamentos: _) in tags)
      if (tag.id != exceto) (nome: tag.nome, arquivado: tag.arquivada == 1),
  ];

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider).value ?? const [];
    final dao = ref.read(bancoProvider).tagsDao;

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      children: [
        Row(
          children: [
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () => abrirJanelaNome(
                context,
                titulo: 'Nova tag',
                rotulo: 'Nome da tag',
                textoApoio: 'O # do começo pode ficar de fora.',
                tipo: Cadastro.tag,
                existentes: _nomes(tags),
                aoSalvar: dao.criar,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nova tag'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListaCadastro(
          textoVazio: 'Nenhuma tag. Elas também podem ser criadas ao lançar.',
          linhas: [
            for (final (:tag, :lancamentos) in tags)
              if (_mostrarArquivadas || tag.arquivada == 0)
                LinhaCadastro(
                  key: ValueKey(tag.id),
                  marca: const MarcaIcone(Icons.sell_outlined),
                  nome: tag.nome,
                  detalhe: [textoUsoTag(lancamentos), if (tag.arquivada == 1) 'arquivada']
                      .join(' · '),
                  arquivado: tag.arquivada == 1,
                  acoes: botoesDeCadastro(
                    arquivado: tag.arquivada == 1,
                    emUso: lancamentos > 0,
                    rotuloEditar: 'Renomear',
                    aoEditar: () => abrirJanelaNome(
                      context,
                      titulo: 'Renomear tag',
                      rotulo: 'Nome da tag',
                      tipo: Cadastro.tag,
                      inicial: tag.nome,
                      existentes: _nomes(tags, exceto: tag.id),
                      aoSalvar: (nome) => dao.renomear(tag.id, nome),
                    ),
                    aoTirar: () => tirarCadastro(
                      context,
                      tipo: Cadastro.tag,
                      nome: tag.nome,
                      emUso: lancamentos > 0,
                      excluir: () => dao.excluir(tag.id),
                      arquivar: () => dao.arquivar(tag.id),
                    ),
                    aoDesarquivar: () => desarquivarCadastro(
                      context,
                      tipo: Cadastro.tag,
                      nome: tag.nome,
                      desarquivar: () => dao.desarquivar(tag.id),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 12),
        CaixaMostrarArquivados(
          rotulo: Cadastro.tag.mostrarArquivados,
          valor: _mostrarArquivadas,
          onChanged: (valor) => setState(() => _mostrarArquivadas = valor),
        ),
      ],
    );
  }
}
