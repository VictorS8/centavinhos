/// Formatação de valores em centavos.
library;

/// Sinal de menos tipográfico, usado em valores negativos ("−R$ 50,00").
const sinalMenos = '−';

/// Formata centavos como "R$ 1.234,56". Negativos saem como "−R$ 1.234,56".
String formatarCentavos(int centavos, {bool negativo = false}) {
  final ehNegativo = negativo || centavos < 0;
  final absoluto = centavos.abs();
  final reais = absoluto ~/ 100;
  final resto = (absoluto % 100).toString().padLeft(2, '0');
  return '${ehNegativo ? sinalMenos : ''}R\$ ${_agruparMilhares(reais)},$resto';
}

String _agruparMilhares(int reais) {
  final digitos = reais.toString();
  final grupos = <String>[];
  for (var fim = digitos.length; fim > 0; fim -= 3) {
    final inicio = fim - 3 < 0 ? 0 : fim - 3;
    grupos.insert(0, digitos.substring(inicio, fim));
  }
  return grupos.join('.');
}
