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

  group('mês da fatura de cada parcela', () {
    test(
      'exemplo do escopo: 3x no dia 06/10 em novembro, dezembro e janeiro',
      () {
        DateTime parcela(int n) => mesDaFaturaDaParcela(
          DateTime(2026, 10, 6),
          parcela: n,
          diaFechamento: 5,
          diaVencimento: 12,
        );
        expect(
          [parcela(1), parcela(2), parcela(3)],
          [DateTime(2026, 11), DateTime(2026, 12), DateTime(2027, 1)],
        );
      },
    );
  });

  group('recálculo ao mudar o cartão', () {
    test('compra que muda de fatura com o novo fechamento', () {
      // Compra em 06/10: fechando dia 5, vai para novembro; fechando dia 10,
      // fica em outubro.
      expect(
        faturaRecalculada(
          data: '2026-10-06',
          mesAtual: '2026-11',
          manual: false,
          diaFechamento: 10,
          diaVencimento: 17,
        ),
        '2026-10',
      );
    });

    test('fatura trocada à mão ou já no mês certo não muda', () {
      expect(
        faturaRecalculada(
          data: '2026-10-06',
          mesAtual: '2026-12',
          manual: true,
          diaFechamento: 10,
          diaVencimento: 17,
        ),
        isNull,
      );
      expect(
        faturaRecalculada(
          data: '2026-10-06',
          mesAtual: '2026-11',
          manual: false,
          diaFechamento: 5,
          diaVencimento: 12,
        ),
        isNull,
      );
    });

    test('parcela mantém a distância da primeira', () {
      expect(
        faturaRecalculada(
          data: '2026-10-06',
          mesAtual: '2027-01',
          manual: false,
          parcela: 3,
          diaFechamento: 10,
          diaVencimento: 17,
        ),
        '2026-12',
      );
    });
  });

  group('fechamento e situação da fatura', () {
    test('fechamento no mês do vencimento ou no anterior', () {
      expect(
        fechamentoDaFatura(
          DateTime(2026, 12),
          diaFechamento: 5,
          diaVencimento: 12,
        ),
        DateTime(2026, 12, 5),
      );
      // Fecha 28, vence 5: a fatura de novembro fecha em 28/10.
      expect(
        fechamentoDaFatura(
          DateTime(2026, 11),
          diaFechamento: 28,
          diaVencimento: 5,
        ),
        DateTime(2026, 10, 28),
      );
      expect(
        fechamentoDaFatura(
          DateTime(2027, 3),
          diaFechamento: 31,
          diaVencimento: 5,
        ),
        DateTime(2027, 2, 28),
      );
    });

    test('situação em 12/10, com um cartão que fecha 5 e vence 12', () {
      SituacaoFatura situacao(DateTime mes, DateTime hoje) => situacaoDaFatura(
        mes,
        hoje: hoje,
        diaFechamento: 5,
        diaVencimento: 12,
      );
      final hoje = DateTime(2026, 10, 12);
      // Vence hoje: já saiu do saldo.
      expect(situacao(DateTime(2026, 10), hoje), SituacaoFatura.paga);
      expect(situacao(DateTime(2026, 9), hoje), SituacaoFatura.paga);
      expect(situacao(DateTime(2026, 11), hoje), SituacaoFatura.aberta);
      expect(situacao(DateTime(2026, 12), hoje), SituacaoFatura.futura);
      // Entre o fechamento (05/10) e o vencimento (12/10), fechada.
      expect(
        situacao(DateTime(2026, 10), DateTime(2026, 10, 5)),
        SituacaoFatura.fechada,
      );
      expect(
        situacao(DateTime(2026, 10), DateTime(2026, 10, 11)),
        SituacaoFatura.fechada,
      );
      expect(
        situacao(DateTime(2026, 10), DateTime(2026, 10, 4)),
        SituacaoFatura.aberta,
      );
    });
  });

  group('total da fatura com estornos e crédito', () {
    List<FaturaDoCartao> faturas(List<MovimentoDaFatura> movimentos) =>
        faturasDoCartao(
          movimentos,
          hoje: DateTime(2026, 10, 12),
          diaFechamento: 5,
          diaVencimento: 12,
        );

    test('total = compras − estornos', () {
      final [novembro, outubro] = faturas([
        (mes: '2026-10', compras: 50000, estornos: 3000, lancamentos: 4),
        (mes: '2026-11', compras: 10000, estornos: 0, lancamentos: 1),
      ]);
      expect(mesIso(outubro.mes), '2026-10');
      expect((outubro.total, outubro.creditoSeguinte), (47000, 0));
      expect((novembro.creditoAnterior, novembro.total), (0, 10000));
      expect(outubro.vencimento, DateTime(2026, 10, 12));
      expect(outubro.fechamento, DateTime(2026, 10, 5));
    });

    test('estornos acima das compras: zero e crédito para a seguinte', () {
      final [dezembro, novembro, outubro] = faturas([
        (mes: '2026-10', compras: 4000, estornos: 10000, lancamentos: 2),
        (mes: '2026-11', compras: 2500, estornos: 0, lancamentos: 1),
        (mes: '2026-12', compras: 9000, estornos: 0, lancamentos: 1),
      ]);
      expect((outubro.total, outubro.creditoSeguinte), (0, 6000));
      // O crédito passa de fatura em fatura até acabar.
      expect(
        (novembro.creditoAnterior, novembro.total, novembro.creditoSeguinte),
        (6000, 0, 3500),
      );
      expect(
        (dezembro.creditoAnterior, dezembro.total, dezembro.creditoSeguinte),
        (3500, 5500, 0),
      );
    });

    test(
      'a fatura aberta aparece mesmo vazia, e a lista vem da mais recente',
      () {
        final lista = faturas([
          (mes: '2026-09', compras: 1000, estornos: 0, lancamentos: 1),
        ]);
        expect([for (final f in lista) mesIso(f.mes)], ['2026-11', '2026-09']);
        expect(lista.first.situacao, SituacaoFatura.aberta);
        expect((lista.first.total, lista.first.lancamentos), (0, 0));
      },
    );
  });
}
