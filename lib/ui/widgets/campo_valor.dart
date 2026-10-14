import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/dinheiro.dart';
import '../../domain/valor_caixa_eletronico.dart';

/// Campo de valor estilo caixa eletrônico: mostra "R$ 0,00" e cada número
/// entra pela direita. Com [permiteNegativo], a tecla "-" troca o sinal.
class CampoValor extends StatefulWidget {
  const CampoValor({
    super.key,
    required this.rotulo,
    this.valorInicial = 0,
    this.permiteNegativo = false,
    this.textoApoio,
    this.onChanged,
  });

  final String rotulo;

  /// Em centavos.
  final int valorInicial;
  final bool permiteNegativo;
  final String? textoApoio;

  /// Recebe o valor em centavos, com sinal.
  final ValueChanged<int>? onChanged;

  @override
  State<CampoValor> createState() => _CampoValorState();
}

class _CampoValorState extends State<CampoValor> {
  late final FormatadorCaixaEletronico _formatador = FormatadorCaixaEletronico(
    permiteNegativo: widget.permiteNegativo,
  );
  late final TextEditingController _controle = TextEditingController(
    text: ValorCaixaEletronico.de(
      widget.valorInicial,
      permiteNegativo: widget.permiteNegativo,
    ).texto,
  );

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controle,
      inputFormatters: [_formatador],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        helperText: widget.textoApoio,
        border: const OutlineInputBorder(),
      ),
      onChanged: (texto) => widget.onChanged?.call(_formatador.ler(texto).centavos),
    );
  }
}

/// Transforma cada edição do campo numa operação do [ValorCaixaEletronico]:
/// número digitado, "-", backspace, texto colado ou tudo selecionado e
/// substituído. O texto mostrado é sempre o valor formatado, com o cursor no
/// fim.
class FormatadorCaixaEletronico extends TextInputFormatter {
  FormatadorCaixaEletronico({required this.permiteNegativo});

  final bool permiteNegativo;

  /// Lê o valor de um texto já formatado pelo campo.
  ValorCaixaEletronico ler(String texto) {
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    return ValorCaixaEletronico(
      absoluto: digitos.isEmpty ? 0 : int.parse(digitos),
      negativo: permiteNegativo && texto.startsWith(sinalMenos),
      permiteNegativo: permiteNegativo,
    );
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue antes, TextEditingValue depois) {
    final a = antes.text;
    final b = depois.text;

    // Acha o trecho que mudou: o que saiu de [a] e o que entrou em [b].
    var prefixo = 0;
    while (prefixo < a.length && prefixo < b.length && a[prefixo] == b[prefixo]) {
      prefixo++;
    }
    var sufixo = 0;
    while (sufixo < a.length - prefixo &&
        sufixo < b.length - prefixo &&
        a[a.length - 1 - sufixo] == b[b.length - 1 - sufixo]) {
      sufixo++;
    }
    final removido = a.substring(prefixo, a.length - sufixo);
    final inserido = b.substring(prefixo, b.length - sufixo);

    var valor = ler(a);
    if (removido.isNotEmpty && removido.length == a.length) {
      valor = valor.limpar();
    } else if (removido.isNotEmpty && inserido.isEmpty) {
      valor = valor.apagar();
    }
    if (inserido.length == 1) {
      valor = valor.digitar(inserido);
    } else if (inserido.length > 1) {
      valor = valor.colar(inserido);
    }

    final texto = valor.texto;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
