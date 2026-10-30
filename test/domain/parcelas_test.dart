import 'package:centavinhos/domain/parcelas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('divisão em parcelas', () {
    test('exemplo do escopo: R\$ 300 em 3x são três de R\$ 100', () {
      expect(dividirEmParcelas(30000, 3), [10000, 10000, 10000]);
    });

    test('os centavos que sobram vão para a primeira parcela', () {
      expect(dividirEmParcelas(10001, 3), [3335, 3333, 3333]);
      expect(dividirEmParcelas(10004, 3), [3336, 3334, 3334]);
      expect(dividirEmParcelas(5, 2), [3, 2]);
    });

    test('a soma das parcelas é sempre o total', () {
      for (final (total, n) in [
        (1999, 7),
        (99999999999, 48),
        (48, 48),
        (12345, 12),
      ]) {
        final parcelas = dividirEmParcelas(total, n);
        expect(parcelas, hasLength(n));
        expect(
          parcelas.reduce((a, b) => a + b),
          total,
          reason: '$total em ${n}x',
        );
        expect(parcelas.every((p) => p > 0), isTrue);
      }
    });

    test('texto da divisão', () {
      expect(textoDasParcelas(30000, 3), '3x de R\$ 100,00');
      expect(textoDasParcelas(30002, 3), '1x de R\$ 100,02 e 2x de R\$ 100,00');
      expect(textoDasParcelas(120000, 12), '12x de R\$ 100,00');
    });

    test('limites de parcelas', () {
      expect(minimoDeParcelas, 2);
      expect(maximoDeParcelas, 48);
    });
  });

  group('categorias em cada parcela', () {
    /// Confere as duas somas: cada parcela bate com o valor dela e cada
    /// categoria, com o valor digitado.
    void conferir(List<int> categorias, int n) {
      final divisao = dividirCategoriasEmParcelas(categorias, n);
      final total = categorias.reduce((a, b) => a + b);
      final parcelas = dividirEmParcelas(total, n);
      expect(divisao, hasLength(n));
      for (var p = 0; p < n; p++) {
        expect(
          divisao[p].reduce((a, b) => a + b),
          parcelas[p],
          reason: 'parcela ${p + 1}',
        );
        expect(
          divisao[p].every((v) => v >= 0),
          isTrue,
          reason: 'parcela ${p + 1}',
        );
      }
      for (var c = 0; c < categorias.length; c++) {
        expect(
          [for (final parcela in divisao) parcela[c]].reduce((a, b) => a + b),
          categorias[c],
          reason: 'categoria ${c + 1}',
        );
      }
    }

    test('uma categoria só segue a divisão da compra', () {
      expect(dividirCategoriasEmParcelas([10001], 3), [
        [3335],
        [3333],
        [3333],
      ]);
    });

    test('divisão exata fica igual em todas as parcelas', () {
      expect(dividirCategoriasEmParcelas([24000, 6000], 3), [
        [8000, 2000],
        [8000, 2000],
        [8000, 2000],
      ]);
    });

    test('com sobra, as somas batem nas parcelas e nas categorias', () {
      conferir([8000, 2001], 3);
      conferir([2, 2, 2], 4);
      conferir([1, 1], 2);
      conferir([12345, 678, 9], 7);
      conferir([99999999990, 9], 48);
    });

    test('poucos centavos: uma categoria pode ficar com zero numa parcela', () {
      final divisao = dividirCategoriasEmParcelas([2, 2, 2], 4);
      expect(divisao.first, [1, 1, 1]);
      expect(divisao.skip(1).every((p) => p.contains(0)), isTrue);
      conferir([2, 2, 2], 4);
    });
  });
}
