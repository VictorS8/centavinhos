import 'package:centavinhos/domain/exclusao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Parcelas fora da ordem dos ids, para conferir que vale a parcela.
  final parcelas = <MembroDoGrupo>[
    (id: 12, data: '2026-10-06', parcela: 3),
    (id: 10, data: '2026-10-06', parcela: 1),
    (id: 11, data: '2026-10-06', parcela: 2),
  ];
  final meses = <MembroDoGrupo>[
    (id: 5, data: '2026-11-05', parcela: null),
    (id: 3, data: '2026-09-05', parcela: null),
    (id: 4, data: '2026-10-05', parcela: null),
  ];

  group('idsAExcluir', () {
    test('só este', () {
      expect(idsAExcluir(id: 11, grupo: parcelas, alcance: AlcanceExclusao.soEste), [11]);
    });

    test('este e os próximos, pela parcela', () {
      expect(idsAExcluir(id: 11, grupo: parcelas, alcance: AlcanceExclusao.esteEOsProximos), [
        11,
        12,
      ]);
      expect(idsAExcluir(id: 10, grupo: parcelas, alcance: AlcanceExclusao.esteEOsProximos), [
        10,
        11,
        12,
      ]);
      expect(idsAExcluir(id: 12, grupo: parcelas, alcance: AlcanceExclusao.esteEOsProximos), [12]);
    });

    test('este e os próximos, pela data na recorrência', () {
      expect(idsAExcluir(id: 4, grupo: meses, alcance: AlcanceExclusao.esteEOsProximos), [4, 5]);
    });

    test('todos, na ordem do grupo', () {
      expect(idsAExcluir(id: 11, grupo: parcelas, alcance: AlcanceExclusao.todos), [10, 11, 12]);
      expect(idsAExcluir(id: 4, grupo: meses, alcance: AlcanceExclusao.todos), [3, 4, 5]);
    });

    test('lançamento sozinho', () {
      final sozinho = <MembroDoGrupo>[(id: 7, data: '2026-10-03', parcela: null)];
      for (final alcance in AlcanceExclusao.values) {
        expect(idsAExcluir(id: 7, grupo: sozinho, alcance: alcance), [7]);
      }
    });
  });

  test('fim da recorrência: o dia anterior, virando o mês e o ano', () {
    expect(fimDaRecorrencia('2026-10-05'), '2026-10-04');
    expect(fimDaRecorrencia('2026-10-01'), '2026-09-30');
    expect(fimDaRecorrencia('2027-01-01'), '2026-12-31');
    expect(fimDaRecorrencia('2028-03-01'), '2028-02-29');
  });
}
