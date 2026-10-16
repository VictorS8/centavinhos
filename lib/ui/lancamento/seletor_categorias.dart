import 'package:material_ui/material_ui.dart';

import '../../domain/multicategoria.dart';
import '../../domain/sugestoes.dart';
import '../widgets/campo_valor.dart';
import 'campo_com_sugestoes.dart';

/// Uma categoria que pode ser escolhida, com o nome como aparece no
/// lançamento ("Casa" ou "Casa, Mercado").
typedef OpcaoCategoria = ({int id, String rotulo});

/// Uma categoria escolhida e o valor digitado para ela (zero é vazio).
typedef ParteEscolhida = ({int id, String rotulo, int valor});

/// Categorias do lançamento: um campo com busca e, embaixo, as escolhidas
/// como etiquetas removíveis. Com duas ou mais, cada uma ganha um campo de
/// valor e aparece o contador do que já foi distribuído.
class SeletorCategorias extends StatefulWidget {
  const SeletorCategorias({
    super.key,
    required this.opcoes,
    required this.escolhidas,
    required this.total,
    required this.geracao,
    required this.aoAdicionar,
    required this.aoTirar,
    required this.aoMudarValor,
    required this.aoEnviar,
  });

  /// As categorias ativas do tipo do lançamento.
  final List<OpcaoCategoria> opcoes;
  final List<ParteEscolhida> escolhidas;

  /// Valor do lançamento, em centavos.
  final int total;

  /// Muda quando as escolhidas são trocadas de uma vez (nome conhecido), para
  /// os campos de valor recomeçarem vazios.
  final int geracao;
  final ValueChanged<OpcaoCategoria> aoAdicionar;
  final ValueChanged<int> aoTirar;
  final void Function(int id, int valor) aoMudarValor;

  /// Enter num campo sem outra coisa para fazer.
  final VoidCallback aoEnviar;

  @override
  State<SeletorCategorias> createState() => _SeletorCategoriasState();
}

class _SeletorCategoriasState extends State<SeletorCategorias> {
  final _busca = TextEditingController();
  final _focoBusca = FocusNode();
  final _focosValor = <int, FocusNode>{};

  FocusNode _focoValor(int id) => _focosValor.putIfAbsent(id, FocusNode.new);

  List<OpcaoCategoria> _sugestoes(String texto) {
    final escolhidas = {for (final parte in widget.escolhidas) parte.id};
    return filtrarPorTexto(
      texto,
      widget.opcoes.where((o) => !escolhidas.contains(o.id)),
      (o) => o.rotulo,
    );
  }

  /// Escolhida na busca: com a segunda categoria, o foco vai para o valor da
  /// primeira; da terceira em diante, para o valor da nova.
  void _adicionar(OpcaoCategoria opcao) {
    final antes = widget.escolhidas.length;
    widget.aoAdicionar(opcao);
    if (antes == 0) return;
    final alvo = antes == 1 ? widget.escolhidas.first.id : opcao.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoValor(alvo).requestFocus();
    });
  }

  @override
  void dispose() {
    _busca.dispose();
    _focoBusca.dispose();
    for (final foco in _focosValor.values) {
      foco.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final varias = widget.escolhidas.length > 1;
    final distribuicao = Distribuicao(
      total: widget.total,
      valores: [for (final parte in widget.escolhidas) parte.valor],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.escolhidas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Categorias', style: tema.textTheme.titleSmall),
          ),
        for (final parte in widget.escolhidas)
          Padding(
            key: ValueKey(('categoria', parte.id)),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _Etiqueta(rotulo: parte.rotulo, aoTirar: () => widget.aoTirar(parte.id)),
                ),
                if (varias) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 150,
                    child: CampoValor(
                      key: ValueKey(('valor', parte.id, widget.geracao)),
                      foco: _focoValor(parte.id),
                      valorInicial: parte.valor,
                      onChanged: (valor) => widget.aoMudarValor(parte.id, valor),
                      onSubmitted: widget.aoEnviar,
                    ),
                  ),
                ],
              ],
            ),
          ),
        CampoComSugestoes<OpcaoCategoria>(
          key: const ValueKey('busca'),
          controle: _busca,
          foco: _focoBusca,
          rotulo: widget.escolhidas.isEmpty ? 'Categoria' : 'Adicionar categoria',
          icone: widget.escolhidas.isEmpty ? null : Icons.add,
          sugestoes: _sugestoes,
          textoDa: (o) => o.rotulo,
          aoEscolher: _adicionar,
          limparAoEscolher: true,
          aoEnviar: widget.aoEnviar,
        ),
        if (varias)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              distribuicao.texto,
              textAlign: TextAlign.end,
              style: tema.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: distribuicao.fecha
                    ? tema.colorScheme.primary
                    : tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Categoria escolhida, com o botão de tirar.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.rotulo, required this.aoTirar});

  final String rotulo;
  final VoidCallback aoTirar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: cores.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.labelLarge?.copyWith(
                color: cores.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Fora do Tab, para ele ir direto aos campos de valor.
          ExcludeFocus(
            child: IconButton(
              onPressed: aoTirar,
              tooltip: 'Tirar $rotulo',
              iconSize: 18,
              color: cores.onSecondaryContainer,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
