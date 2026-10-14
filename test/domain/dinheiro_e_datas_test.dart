import 'package:centavinhos/domain/datas.dart';
import 'package:centavinhos/domain/dinheiro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatarCentavos', () {
    test('valores pequenos', () {
      expect(formatarCentavos(0), 'R\$ 0,00');
      expect(formatarCentavos(5), 'R\$ 0,05');
      expect(formatarCentavos(1250), 'R\$ 12,50');
    });

    test('milhares', () {
      expect(formatarCentavos(100000), 'R\$ 1.000,00');
      expect(formatarCentavos(328450), 'R\$ 3.284,50');
      expect(formatarCentavos(99999999999), 'R\$ 999.999.999,99');
    });

    test('negativo com o sinal de menos tipográfico', () {
      expect(formatarCentavos(-5000), '−R\$ 50,00');
      expect(formatarCentavos(0, negativo: true), '−R\$ 0,00');
    });
  });

  group('datas', () {
    test('dia e mês no formato do banco', () {
      final data = DateTime(2026, 3, 7);
      expect(dataIso(data), '2026-03-07');
      expect(mesIso(data), '2026-03');
    });
  });
}
