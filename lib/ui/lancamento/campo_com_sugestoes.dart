import 'package:material_ui/material_ui.dart';

/// Campo de texto com sugestões numa lista embaixo, escolhidas com as setas
/// e o Enter ou com um clique. Esc fecha a lista; com ela fechada, Esc segue
/// para a janela.
///
/// O Enter escolhe a sugestão marcada quando a lista está aberta e, quando
/// ela está fechada, chama [aoEnviar].
class CampoComSugestoes<T extends Object> extends StatefulWidget {
  const CampoComSugestoes({
    super.key,
    required this.controle,
    required this.foco,
    required this.rotulo,
    required this.sugestoes,
    required this.textoDa,
    required this.aoEscolher,
    this.aoEnviar,
    this.limparAoEscolher = false,
    this.autofocus = false,
    this.icone,
    this.textoApoio,
  });

  final TextEditingController controle;
  final FocusNode foco;
  final String rotulo;

  /// As sugestões para o texto digitado.
  final List<T> Function(String texto) sugestoes;
  final String Function(T item) textoDa;
  final ValueChanged<T> aoEscolher;

  /// Enter com a lista de sugestões fechada.
  final VoidCallback? aoEnviar;

  /// Se o campo fica vazio depois de uma escolha, pronto para a próxima.
  final bool limparAoEscolher;
  final bool autofocus;
  final IconData? icone;
  final String? textoApoio;

  @override
  State<CampoComSugestoes<T>> createState() => _CampoComSugestoesState<T>();
}

class _CampoComSugestoesState<T extends Object> extends State<CampoComSugestoes<T>> {
  /// Se a lista de sugestões está na tela. O [RawAutocomplete] não conta,
  /// então a própria lista avisa quando aparece e quando some.
  var _listaAberta = false;

  /// Texto já escolhido (ou que já veio preenchido, numa edição). Enquanto o
  /// campo mostrar exatamente ele, a lista não reabre ao voltar ao campo.
  late String _escolhido;

  @override
  void initState() {
    super.initState();
    _escolhido = widget.controle.text;
  }

  bool get _mostraEscolhido =>
      widget.controle.text.isNotEmpty && widget.controle.text == _escolhido;

  List<T> _sugestoes(String texto) =>
      texto.isNotEmpty && texto == _escolhido ? <T>[] : widget.sugestoes(texto);

  void _escolher(T item) {
    _escolhido = widget.textoDa(item);
    widget.aoEscolher(item);
    // Limpar depois da escolha, e não durante: o RawAutocomplete ignora
    // mudanças de texto no meio dela e ficaria com as sugestões antigas.
    if (widget.limparAoEscolher) Future.microtask(widget.controle.clear);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: widget.controle,
      focusNode: widget.foco,
      optionsBuilder: (valor) => _sugestoes(valor.text),
      displayStringForOption: widget.textoDa,
      onSelected: _escolher,
      // O Builder dá um contexto abaixo das ações do RawAutocomplete.
      fieldViewBuilder: (_, controle, foco, aoConfirmar) => Builder(
        builder: (contextoCampo) => Actions(
          actions: {
            // Com a lista à vista, o Esc vai para o RawAutocomplete, que fecha
            // a lista. Sem ela, vai direto para a janela: o RawAutocomplete
            // usaria o Esc para "fechar" uma lista vazia e a janela só
            // fecharia no segundo Esc.
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intencao) =>
                  Actions.maybeInvoke(_listaAberta ? contextoCampo : context, intencao),
            ),
          },
          child: TextField(
            controller: controle,
            focusNode: foco,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              labelText: widget.rotulo,
              helperText: widget.textoApoio,
              prefixIcon: widget.icone == null ? null : Icon(widget.icone),
              border: const OutlineInputBorder(),
            ),
            // Sem isto, o Enter tiraria o foco do campo.
            onEditingComplete: () {},
            onSubmitted: (_) => _listaAberta ? aoConfirmar() : widget.aoEnviar?.call(),
          ),
        ),
      ),
      // Ao voltar ao campo, o RawAutocomplete reabre a lista da última busca
      // sem perguntar de novo. Com o texto já escolhido, ela fica vazia.
      optionsViewBuilder: (context, aoEscolher, opcoes) => _mostraEscolhido
          ? const SizedBox.shrink()
          : _ListaSugestoes<T>(
              opcoes: opcoes.toList(),
              textoDa: widget.textoDa,
              aoEscolher: aoEscolher,
              aoMudarVisivel: (aberta) => _listaAberta = aberta,
            ),
    );
  }
}

class _ListaSugestoes<T extends Object> extends StatefulWidget {
  const _ListaSugestoes({
    required this.opcoes,
    required this.textoDa,
    required this.aoEscolher,
    required this.aoMudarVisivel,
  });

  final List<T> opcoes;
  final String Function(T item) textoDa;
  final ValueChanged<T> aoEscolher;
  final ValueChanged<bool> aoMudarVisivel;

  @override
  State<_ListaSugestoes<T>> createState() => _ListaSugestoesState<T>();
}

class _ListaSugestoesState<T extends Object> extends State<_ListaSugestoes<T>> {
  static const _alturaItem = 44.0;
  final _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.aoMudarVisivel(true);
  }

  @override
  void dispose() {
    widget.aoMudarVisivel(false);
    _rolagem.dispose();
    super.dispose();
  }

  /// Rola a lista para a sugestão marcada pelas setas ficar visível.
  void _mostrarMarcada(int indice) {
    if (!_rolagem.hasClients) return;
    final posicao = _rolagem.position;
    final topo = indice * _alturaItem;
    if (topo < posicao.pixels) {
      _rolagem.jumpTo(topo);
    } else if (topo + _alturaItem > posicao.pixels + posicao.viewportDimension) {
      _rolagem.jumpTo(topo + _alturaItem - posicao.viewportDimension);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final marcada = AutocompleteHighlightedOption.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarMarcada(marcada));
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      // Contorno em vez de sombra: a lista se destaca dos campos embaixo dela
      // e aparece igual nas capturas de tela dos testes, que não desenham
      // sombras.
      child: Material(
        color: tema.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: tema.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _alturaItem * 6 + 8),
          child: ListView.builder(
            controller: _rolagem,
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemExtent: _alturaItem,
            itemCount: widget.opcoes.length,
            itemBuilder: (context, indice) {
              final item = widget.opcoes[indice];
              return InkWell(
                onTap: () => widget.aoEscolher(item),
                child: Container(
                  color: indice == marcada ? tema.colorScheme.secondaryContainer : null,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.textoDa(item),
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.bodyLarge?.copyWith(
                      color: indice == marcada
                          ? tema.colorScheme.onSecondaryContainer
                          : tema.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
