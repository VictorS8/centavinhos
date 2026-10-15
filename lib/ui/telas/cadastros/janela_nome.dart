import 'package:material_ui/material_ui.dart';

import '../../../domain/cadastros.dart';
import '../../widgets/janela_formulario.dart';

/// Abre a janela de um cadastro que só tem nome: categoria, subcategoria ou
/// tag. [existentes] são os outros nomes do mesmo grupo, para não repetir.
Future<void> abrirJanelaNome(
  BuildContext context, {
  required String titulo,
  required String rotulo,
  required Cadastro tipo,
  required Iterable<NomeExistente> existentes,
  required Future<void> Function(String nome) aoSalvar,
  String inicial = '',
  String? textoApoio,
}) => showDialog<void>(
  context: context,
  builder: (_) => JanelaNome(
    titulo: titulo,
    rotulo: rotulo,
    tipo: tipo,
    existentes: existentes.toList(),
    aoSalvar: aoSalvar,
    inicial: inicial,
    textoApoio: textoApoio,
  ),
);

class JanelaNome extends StatefulWidget {
  const JanelaNome({
    super.key,
    required this.titulo,
    required this.rotulo,
    required this.tipo,
    required this.existentes,
    required this.aoSalvar,
    this.inicial = '',
    this.textoApoio,
  });

  final String titulo;
  final String rotulo;
  final Cadastro tipo;
  final List<NomeExistente> existentes;
  final Future<void> Function(String nome) aoSalvar;
  final String inicial;
  final String? textoApoio;

  @override
  State<JanelaNome> createState() => _JanelaNomeState();
}

class _JanelaNomeState extends State<JanelaNome> {
  late final _nome = TextEditingController(text: widget.inicial)
    ..addListener(() => setState(() {}));
  var _salvando = false;

  String? get _motivo =>
      motivoNomeInvalido(_nome.text, widget.tipo, existentes: widget.existentes);

  Future<void> _salvar() async {
    if (_motivo != null || _salvando) return;
    setState(() => _salvando = true);
    try {
      await widget.aoSalvar(_nome.text);
      if (mounted) Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisarErroAoSalvar(context, erro);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JanelaFormulario(
      titulo: widget.titulo,
      motivoBloqueio: _motivo,
      salvando: _salvando,
      aoSalvar: _salvar,
      campos: [
        TextField(
          controller: _nome,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.rotulo,
            helperText: widget.textoApoio,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _salvar(),
        ),
      ],
    );
  }
}
