import 'dinheiro.dart';

/// Valor digitado estilo caixa eletrônico: o campo começa em "R$ 0,00" e cada
/// número entra pela direita (1, 2, 5, 0 → R$ 0,01, R$ 0,12, R$ 1,25,
/// R$ 12,50). Backspace apaga o último número; vírgula e ponto são ignorados.
///
/// Quando [permiteNegativo] está ligado (só no saldo inicial das contas), a
/// tecla "-" troca o sinal. O sinal fica guardado à parte, para o campo poder
/// mostrar "−R$ 0,00" antes de qualquer número ser digitado.
class ValorCaixaEletronico {
  const ValorCaixaEletronico({
    this.absoluto = 0,
    this.negativo = false,
    this.permiteNegativo = false,
  }) : assert(absoluto >= 0),
       assert(!negativo || permiteNegativo);

  /// Começa com o valor [centavos], que só pode ser negativo se
  /// [permiteNegativo] estiver ligado.
  factory ValorCaixaEletronico.de(
    int centavos, {
    bool permiteNegativo = false,
  }) {
    assert(centavos >= 0 || permiteNegativo);
    return ValorCaixaEletronico(
      absoluto: centavos.abs(),
      negativo: centavos < 0,
      permiteNegativo: permiteNegativo,
    );
  }

  /// Até R$ 999.999.999,99.
  static const maximoDigitos = 11;
  static const maximoCentavos = 99999999999;

  final int absoluto;
  final bool negativo;
  final bool permiteNegativo;

  /// O valor com sinal, em centavos.
  int get centavos => negativo ? -absoluto : absoluto;

  /// Texto mostrado no campo, como "R$ 12,50" ou "−R$ 200,00".
  String get texto => formatarCentavos(absoluto, negativo: negativo);

  ValorCaixaEletronico _com({int? absoluto, bool? negativo}) =>
      ValorCaixaEletronico(
        absoluto: absoluto ?? this.absoluto,
        negativo: negativo ?? this.negativo,
        permiteNegativo: permiteNegativo,
      );

  /// Aplica uma tecla: número entra pela direita, "-" troca o sinal (se
  /// permitido) e qualquer outra coisa é ignorada.
  ValorCaixaEletronico digitar(String tecla) {
    if (tecla == '-') return trocarSinal();
    final digito = int.tryParse(tecla);
    if (tecla.length != 1 || digito == null) return this;
    final novo = absoluto * 10 + digito;
    if (novo > maximoCentavos) return this;
    return _com(absoluto: novo);
  }

  /// Apaga o último número. Com o valor zerado, também tira o sinal.
  ValorCaixaEletronico apagar() {
    if (absoluto == 0) return _com(negativo: false);
    return _com(absoluto: absoluto ~/ 10);
  }

  /// Troca o sinal. Sem [permiteNegativo], não faz nada.
  ValorCaixaEletronico trocarSinal() {
    if (!permiteNegativo) return this;
    return _com(negativo: !negativo);
  }

  /// Volta para "R$ 0,00".
  ValorCaixaEletronico limpar() => _com(absoluto: 0, negativo: false);

  /// Interpreta um texto colado, como "12,50", "R$ 1.234,56" ou "300".
  ///
  /// Vírgula ou ponto seguidos de um ou dois números no fim marcam os
  /// centavos; sem eles, o texto é lido como reais ("300" vira R$ 300,00).
  /// Com [permiteNegativo], um "-" ou "−" no texto deixa o valor negativo.
  /// Devolve o próprio valor, sem mudança, se o texto não tiver números ou
  /// passar do máximo.
  ValorCaixaEletronico colar(String textoColado) {
    final texto = textoColado.trim();
    final decimal = RegExp(r'[.,](\d{1,2})$').firstMatch(texto);
    final parteInteira = decimal == null
        ? texto
        : texto.substring(0, decimal.start);
    final digitosInteiros = parteInteira.replaceAll(RegExp(r'\D'), '');
    final centavosTexto = (decimal?.group(1) ?? '').padRight(2, '0');
    if (digitosInteiros.isEmpty && decimal == null) return this;

    final reais = digitosInteiros.isEmpty ? '0' : digitosInteiros;
    // Evita estouro antes de converter: o máximo tem 9 números de reais.
    final reaisSemZeros = reais.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (reaisSemZeros.length > maximoDigitos - 2) return this;

    final novo = int.parse(reaisSemZeros) * 100 + int.parse(centavosTexto);
    if (novo > maximoCentavos) return this;
    final temMenos = texto.contains('-') || texto.contains(sinalMenos);
    return _com(absoluto: novo, negativo: permiteNegativo && temMenos);
  }

  @override
  bool operator ==(Object other) =>
      other is ValorCaixaEletronico &&
      other.absoluto == absoluto &&
      other.negativo == negativo &&
      other.permiteNegativo == permiteNegativo;

  @override
  int get hashCode => Object.hash(absoluto, negativo, permiteNegativo);

  @override
  String toString() => 'ValorCaixaEletronico($texto)';
}
