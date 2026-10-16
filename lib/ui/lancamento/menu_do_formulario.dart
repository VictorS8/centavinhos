import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Menu de escolha do formulário de lançamento (Recorrência, Conta ou cartão
/// e Fatura). Digitar abre o menu e marca a primeira opção que combina, e o
/// Enter escolhe. Com o menu fechado, o Enter chama [aoEnviar] e o Esc
/// chama [aoCancelar] (o menu sozinho engoliria o Esc sem fechar a janela).
///
/// O campo mostra sempre a opção escolhida: quando ela muda por fora e, ao
/// sair do campo, depois de um texto digitado que não virou escolha.
class MenuDoFormulario<T> extends StatefulWidget {
  const MenuDoFormulario({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.escolhida,
    required this.aoEscolher,
    this.textoApoio,
    this.aoEnviar,
    this.aoCancelar,
  });

  final String rotulo;
  final List<DropdownMenuEntry<T>> opcoes;
  final T? escolhida;
  final ValueChanged<T> aoEscolher;
  final String? textoApoio;
  final VoidCallback? aoEnviar;
  final VoidCallback? aoCancelar;

  @override
  State<MenuDoFormulario<T>> createState() => _MenuDoFormularioState<T>();
}

class _MenuDoFormularioState<T> extends State<MenuDoFormulario<T>> {
  final _menu = MenuController();
  final _texto = TextEditingController();

  // As teclas chegam primeiro ao foco do campo, antes dos atalhos do menu.
  late final FocusNode _foco = FocusNode(onKeyEvent: _aoTeclar)
    ..addListener(() {
      if (!_foco.hasFocus) _mostrarEscolhida();
    });

  /// A seta do menu fica fora do Tab, que vai direto ao próximo campo.
  final _focoSeta = FocusNode(skipTraversal: true);

  String _rotuloDe(MenuDoFormulario<T> menu) =>
      menu.opcoes.where((o) => o.value == menu.escolhida).firstOrNull?.label ?? '';

  void _mostrarEscolhida() {
    if (!mounted) return;
    final texto = _rotuloDe(widget);
    if (_texto.text != texto) _texto.text = texto;
  }

  @override
  void initState() {
    super.initState();
    _texto.text = _rotuloDe(widget);
  }

  @override
  void didUpdateWidget(MenuDoFormulario<T> antigo) {
    super.didUpdateWidget(antigo);
    final mudou = antigo.escolhida != widget.escolhida || _rotuloDe(antigo) != _rotuloDe(widget);
    // Fora do build, para não mexer no campo no meio dele.
    if (mudou || !_foco.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarEscolhida());
    }
  }

  @override
  void dispose() {
    _foco.dispose();
    _focoSeta.dispose();
    _texto.dispose();
    super.dispose();
  }

  KeyEventResult _aoTeclar(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent || _menu.isOpen) return KeyEventResult.ignored;
    if (evento.logicalKey == LogicalKeyboardKey.enter && widget.aoEnviar != null) {
      widget.aoEnviar!();
      return KeyEventResult.handled;
    }
    if (evento.logicalKey == LogicalKeyboardKey.escape && widget.aoCancelar != null) {
      widget.aoCancelar!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      controller: _texto,
      focusNode: _foco,
      trailingIconFocusNode: _focoSeta,
      menuController: _menu,
      initialSelection: widget.escolhida,
      label: Text(widget.rotulo),
      helperText: widget.textoApoio,
      expandedInsets: EdgeInsets.zero,
      // Sem isto, nos testes (que fingem ser um celular) o menu não
      // receberia o foco pelo Tab.
      requestFocusOnTap: true,
      menuHeight: 320,
      dropdownMenuEntries: widget.opcoes,
      onSelected: (valor) {
        if (valor == null) return;
        widget.aoEscolher(valor);
        // O Enter que escolhe também tira o foco do campo; ele volta, para o
        // Tab seguir daqui.
        _foco.requestFocus();
      },
    );
  }
}
