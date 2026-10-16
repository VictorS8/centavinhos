/// Divisão do valor de um lançamento entre duas ou mais categorias.
library;

import 'dinheiro.dart';

/// Quanto do [total] já foi distribuído entre as categorias. Cada valor é o
/// digitado para uma categoria, em centavos; zero é um campo vazio.
class Distribuicao {
  Distribuicao({required this.total, required List<int> valores})
    : valores = List.unmodifiable(valores),
      distribuido = valores.fold(0, (soma, valor) => soma + valor);

  final int total;
  final List<int> valores;
  final int distribuido;

  /// Quanto falta distribuir. Negativo quando passou do total.
  int get falta => total - distribuido;

  /// Se toda categoria tem valor e a soma é igual ao total.
  bool get fecha => total > 0 && falta == 0 && valores.every((valor) => valor > 0);

  /// "Distribuído R$ 80,00 de R$ 100,00, faltam R$ 20,00", com "sobram"
  /// quando passou do total e sem o fim quando bate.
  String get texto {
    final inicio = 'Distribuído ${formatarCentavos(distribuido)} de ${formatarCentavos(total)}';
    if (falta > 0) return '$inicio, faltam ${formatarCentavos(falta)}';
    if (falta < 0) return '$inicio, sobram ${formatarCentavos(-falta)}';
    return inicio;
  }
}
