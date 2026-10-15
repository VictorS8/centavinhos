import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/data_digitada.dart';
import '../../domain/datas.dart';

/// Campo de data: aceita dd/mm (completa o ano de [hoje]) ou dd/mm/aaaa, e
/// tem um botão de calendário. Ao sair do campo, a data válida é reescrita
/// como dd/mm/aaaa.
class CampoData extends StatefulWidget {
  const CampoData({
    super.key,
    required this.rotulo,
    required this.hoje,
    this.valorInicial,
    this.ultimaData,
    this.textoApoio,
    this.onChanged,
    this.onSubmitted,
  });

  final String rotulo;
  final DateTime hoje;
  final DateTime? valorInicial;

  /// Última data que o calendário oferece.
  final DateTime? ultimaData;
  final String? textoApoio;

  /// Recebe a data digitada, ou nulo quando o texto não é uma data válida.
  final ValueChanged<DateTime?>? onChanged;

  /// Enter no campo.
  final VoidCallback? onSubmitted;

  @override
  State<CampoData> createState() => _CampoDataState();
}

class _CampoDataState extends State<CampoData> {
  static final _primeiraData = DateTime(2000);

  late final _controle = TextEditingController(
    text: widget.valorInicial == null ? '' : dataBr(widget.valorInicial!),
  );
  late final _foco = FocusNode()..addListener(_aoMudarFoco);

  DateTime? _ler() => lerDataDigitada(_controle.text, hoje: widget.hoje);

  void _aoMudarFoco() {
    if (_foco.hasFocus) return;
    final data = _ler();
    if (data != null && _controle.text != dataBr(data)) _controle.text = dataBr(data);
  }

  Future<void> _abrirCalendario() async {
    final ultima = widget.ultimaData ?? DateTime(2100);
    var inicial = _ler() ?? widget.hoje;
    if (inicial.isAfter(ultima)) inicial = ultima;
    if (inicial.isBefore(_primeiraData)) inicial = _primeiraData;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: _primeiraData,
      lastDate: ultima,
      currentDate: widget.hoje,
    );
    if (escolhida == null || !mounted) return;
    _controle.text = dataBr(escolhida);
    widget.onChanged?.call(escolhida);
  }

  @override
  void dispose() {
    _controle.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controle,
      focusNode: _foco,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: widget.rotulo,
        hintText: 'dd/mm/aaaa',
        helperText: widget.textoApoio,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: _abrirCalendario,
          tooltip: 'Abrir calendário',
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
      onChanged: (_) => widget.onChanged?.call(_ler()),
      onSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
    );
  }
}
