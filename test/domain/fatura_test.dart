import 'package:centavinhos/domain/datas.dart';
import 'package:centavinhos/domain/fatura.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime fatura(DateTime compra, {required int fecha, required int vence}) =>
      mesDaFatura(compra, diaFechamento: fecha, diaVencimento: vence);

  group('mês da fatura', () {
    test('exemplo do escopo: fecha dia 5 e vence dia 12', () {
      expect(fatura(DateTime(2026, 10, 3), fecha: 5, vence: 12), DateTime(2026, 10));
      expect(fatura(DateTime(2026, 10, 6), fecha: 5, vence: 12), DateTime(2026, 11));
    });

    test('compra no dia do fechamento vai para a fatura seguinte', () {
      expect(fatura(DateTime(2026, 10, 5), fecha: 5, vence: 12), DateTime(2026, 11));
      expect(fatura(DateTime(2026, 10, 4), fecha: 5, vence: 12), DateTime(2026, 10));
    });

    test('vencimento antes do fechamento cai no mês seguinte ao fechamento', () {
      // Fecha 28, vence 5: a fatura que fecha em 28/10 vence em 05/11.
      expect(fatura(DateTime(2026, 10, 27), fecha: 28, vence: 5), DateTime(2026, 11));
      expect(fatura(DateTime(2026, 10, 28), fecha: 28, vence: 5), DateTime(2026, 12));
    });

    test('virada do ano', () {
      expect(fatura(DateTime(2026, 12, 10), fecha: 5, vence: 12), DateTime(2027, 1));
      expect(fatura(DateTime(2026, 12, 29), fecha: 28, vence: 5), DateTime(2027, 2));
    });

    test('fechamento no dia 31 vira o último dia dos meses mais curtos', () {
      // Abril tem 30 dias: o fechamento cai em 30/04.
      expect(fatura(DateTime(2026, 4, 29), fecha: 31, vence: 10), DateTime(2026, 5));
      expect(fatura(DateTime(2026, 4, 30), fecha: 31, vence: 10), DateTime(2026, 6));
      // Fevereiro de 2026 tem 28 dias e o de 2028, 29.
      expect(fatura(DateTime(2026, 2, 27), fecha: 31, vence: 10), DateTime(2026, 3));
      expect(fatura(DateTime(2026, 2, 28), fecha: 31, vence: 10), DateTime(2026, 4));
      expect(fatura(DateTime(2028, 2, 28), fecha: 30, vence: 10), DateTime(2028, 3));
      expect(fatura(DateTime(2028, 2, 29), fecha: 30, vence: 10), DateTime(2028, 4));
    });

    test('compra no dia 31 com fechamento no 31', () {
      expect(fatura(DateTime(2026, 10, 30), fecha: 31, vence: 10), DateTime(2026, 11));
      expect(fatura(DateTime(2026, 10, 31), fecha: 31, vence: 10), DateTime(2026, 12));
    });
  });

  group('vencimento da fatura', () {
    test('dia do vencimento no mês da fatura', () {
      expect(vencimentoDaFatura(DateTime(2026, 11), diaVencimento: 12), DateTime(2026, 11, 12));
    });

    test('dia que não existe no mês vira o último dia', () {
      expect(vencimentoDaFatura(DateTime(2026, 4), diaVencimento: 31), DateTime(2026, 4, 30));
      expect(vencimentoDaFatura(DateTime(2026, 2), diaVencimento: 30), DateTime(2026, 2, 28));
      expect(vencimentoDaFatura(DateTime(2028, 2), diaVencimento: 30), DateTime(2028, 2, 29));
    });
  });

  group('datas da fatura', () {
    test('mês por extenso e leitura de AAAA-MM', () {
      expect(mesAnoBr(DateTime(2026, 11)), 'Novembro/2026');
      expect(mesAnoBr(DateTime(2027, 3)), 'Março/2027');
      expect(lerMesIso('2026-11'), DateTime(2026, 11));
    });

    test('último dia do mês e dia no mês, passando de dezembro', () {
      expect(ultimoDiaDoMes(2026, 2), 28);
      expect(ultimoDiaDoMes(2028, 2), 29);
      expect(ultimoDiaDoMes(2026, 12), 31);
      expect(diaNoMes(2026, 13, 31), DateTime(2027, 1, 31));
      expect(diaNoMes(2026, 14, 31), DateTime(2027, 2, 28));
    });
  });
}
