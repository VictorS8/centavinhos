import 'package:centavinhos/domain/data_digitada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hoje = DateTime(2026, 10, 12);
  DateTime? ler(String texto) => lerDataDigitada(texto, hoje: hoje);

  test('dd/mm completa com o ano de hoje', () {
    expect(ler('15/10'), DateTime(2026, 10, 15));
    expect(ler('01/01'), DateTime(2026, 1, 1));
  });

  test('dd/mm/aaaa', () {
    expect(ler('15/10/2026'), DateTime(2026, 10, 15));
    expect(ler('31/12/2025'), DateTime(2025, 12, 31));
  });

  test('aceita dia e mês com um número só e espaços', () {
    expect(ler('1/9'), DateTime(2026, 9, 1));
    expect(ler(' 5 / 10 / 2026 '), DateTime(2026, 10, 5));
  });

  test('datas que não existem', () {
    expect(ler('31/02'), isNull);
    expect(ler('31/04/2026'), isNull);
    expect(ler('00/10'), isNull);
    expect(ler('10/13'), isNull);
    expect(ler('10/00'), isNull);
  });

  test('29/02 só em ano bissexto', () {
    expect(ler('29/02/2028'), DateTime(2028, 2, 29));
    expect(ler('29/02/2026'), isNull);
    expect(ler('29/02'), isNull);
  });

  test('textos que não são data', () {
    expect(ler(''), isNull);
    expect(ler('15'), isNull);
    expect(ler('15/10/26'), isNull);
    expect(ler('15-10-2026'), isNull);
    expect(ler('ontem'), isNull);
    expect(ler('15/10/2026/1'), isNull);
  });
}
