import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../domain/datas.dart';
import '../../../domain/dinheiro.dart';
import '../../../domain/mes.dart';
import '../../theme/app_theme.dart';

/// Um lançamento na lista do mês: inicial da categoria, nome com as
/// etiquetas, categoria e conta ou cartão embaixo, valor e data à direita.
/// Clique ou Enter chama [aoAbrir]; a tecla Delete, [aoExcluir].
///
/// Com o foco do teclado, a linha ganha o anel de foco dos botões, por
/// dentro dela: o clareado do Material 3 sozinho quase não aparece.
class LinhaLancamento extends StatefulWidget {
  const LinhaLancamento({
    super.key,
    required this.item,
    required this.aoAbrir,
    required this.aoExcluir,
  });

  final ItemDoMes item;
  final VoidCallback aoAbrir;
  final VoidCallback aoExcluir;

  @override
  State<LinhaLancamento> createState() => _LinhaLancamentoState();
}

class _LinhaLancamentoState extends State<LinhaLancamento> {
  var _comFoco = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_mudouModo);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_mudouModo);
    super.dispose();
  }

  void _mudouModo(FocusHighlightMode _) => setState(() {});

  /// Como no clareado do Material 3: só com o foco vindo do teclado. Um
  /// clique com o mouse não acende o anel.
  bool get _mostrarAnel =>
      _comFoco && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final textos = tema.textTheme;
    final corDoValor = switch (item.tipo) {
      'ganho' => cores.primary,
      'transferencia' => cores.onSurfaceVariant,
      _ => cores.onSurface,
    };

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.delete): widget.aoExcluir},
      child: InkWell(
        onTap: widget.aoAbrir,
        onFocusChange: (comFoco) => setState(() => _comFoco = comFoco),
        child: DecoratedBox(
          key: const ValueKey('anel'),
          position: DecorationPosition.foreground,
          decoration: _mostrarAnel
              ? BoxDecoration(
                  border: Border.fromBorderSide(
                    anelDeFoco(cores).copyWith(strokeAlign: BorderSide.strokeAlignInside),
                  ),
                  borderRadius: BorderRadius.circular(12),
                )
              : const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cores.secondaryContainer,
                  foregroundColor: cores.onSecondaryContainer,
                  child: item.transferencia
                      ? const Icon(Icons.swap_horiz, size: 20)
                      : Text(
                          item.inicial,
                          style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.nome,
                              overflow: TextOverflow.ellipsis,
                              style: textos.bodyLarge,
                            ),
                          ),
                          if (item.categoriasAMais > 0) ...[
                            const SizedBox(width: 8),
                            _EtiquetaDivisao(item: item),
                          ],
                          if (item.mensal) ...[const SizedBox(width: 8), const _Etiqueta('mensal')],
                          if (item.tipo == 'estorno') ...[
                            const SizedBox(width: 8),
                            const _Etiqueta('estorno'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.detalhe,
                        overflow: TextOverflow.ellipsis,
                        style: textos.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.valorNaLista,
                      style: textos.titleLarge?.copyWith(fontSize: 18, color: corDoValor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      diaMesBr(item.data),
                      style: textos.bodySmall?.copyWith(color: cores.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta com contorno, como "mensal" e "estorno".
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: cores.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cores.onSurface),
        ),
      ),
    );
  }
}

/// Etiqueta "+1 categoria", preenchida com a cor terciária. Um clique abre a
/// divisão, com o valor de cada categoria. Fica fora do Tab: a divisão
/// também aparece na janela de edição.
///
/// A divisão não tem nada que receba o foco, então o Esc do menu não
/// chegaria até ela: ao abrir, ela pega o foco e fecha com o próprio Esc;
/// ao fechar, o foco volta para onde estava.
class _EtiquetaDivisao extends StatefulWidget {
  const _EtiquetaDivisao({required this.item});

  final ItemDoMes item;

  @override
  State<_EtiquetaDivisao> createState() => _EtiquetaDivisaoState();
}

class _EtiquetaDivisaoState extends State<_EtiquetaDivisao> {
  final _controle = MenuController();
  final _foco = FocusNode(debugLabel: 'divisão');
  FocusNode? _focoAnterior;

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  void _aoAbrir() {
    _focoAnterior = FocusManager.instance.primaryFocus;
    // A caixa só existe depois do próximo quadro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controle.isOpen) _foco.requestFocus();
    });
  }

  void _aoFechar() {
    final anterior = _focoAnterior;
    _focoAnterior = null;
    if (_foco.hasFocus && anterior != null && anterior.context != null) anterior.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final mais = item.categoriasAMais;
    return MenuAnchor(
      controller: _controle,
      onOpen: _aoAbrir,
      onClose: _aoFechar,
      consumeOutsideTap: true,
      // Contorno no lugar da sombra, como as listas de sugestões.
      style: MenuStyle(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(cores.surfaceContainer),
        side: WidgetStatePropertyAll(BorderSide(color: cores.outlineVariant)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
      ),
      menuChildren: [
        CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): _controle.close},
          child: Focus(
            focusNode: _foco,
            child: _Divisao(item: item),
          ),
        ),
      ],
      builder: (context, controle, _) => ExcludeFocus(
        child: Tooltip(
          message: 'Ver a divisão',
          child: InkWell(
            onTap: () => controle.isOpen ? controle.close() : controle.open(),
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cores.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  '+$mais ${mais == 1 ? 'categoria' : 'categorias'}',
                  style: tema.textTheme.labelSmall?.copyWith(
                    color: cores.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A divisão de um lançamento entre as categorias, com o total embaixo.
class _Divisao extends StatelessWidget {
  const _Divisao({required this.item});

  final ItemDoMes item;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final apoio = textos.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant);
    final valor = textos.titleLarge?.copyWith(fontSize: 16);

    TableRow linha(String rotulo, String texto, {TextStyle? estilo}) => TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(rotulo, style: estilo ?? textos.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
          child: Text(texto, textAlign: TextAlign.right, style: valor),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Divisão', style: textos.titleSmall),
        const SizedBox(height: 8),
        Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            for (final categoria in item.categorias)
              linha(
                categoria.rotulo,
                formatarCentavos(categoria.valorCentavos, negativo: item.tipo == 'estorno'),
              ),
            linha('Total', item.valorNaLista, estilo: apoio),
          ],
        ),
      ],
    );
  }
}
