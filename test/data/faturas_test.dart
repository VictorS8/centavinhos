import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/domain/datas.dart';
import 'package:centavinhos/domain/fatura.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final hoje = DateTime(2026, 10, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await gerarDadosExemplo(db, hoje: hoje);
  });
  tearDown(() => db.close());

  Future<Cartao> cartao(String nome) =>
      (db.select(db.cartoes)..where((c) => c.nome.equals(nome))).getSingle();

  Future<List<FaturaDoCartao>> faturas(String nome) async {
    final c = await cartao(nome);
    return faturasDoCartao(
      await db.faturasDao.observar(c.id).first,
      hoje: hoje,
      diaFechamento: c.diaFechamento,
      diaVencimento: c.diaVencimento,
    );
  }

  group('faturas', () {
    test('Nubank: compras − estornos em cada mês, da mais recente para a mais antiga', () async {
      final lista = await faturas('Nubank');
      expect([for (final f in lista) mesIso(f.mes)], ['2026-12', '2026-11', '2026-10']);
      final outubro = lista.last;
      // Mercado, Fone (1/3), Combustível e Restaurante, menos o estorno de R$ 30.
      expect(outubro.compras, 41230 + 10000 + 25000 + 13600);
      expect(outubro.estornos, 3000);
      expect(outubro.total, 41230 + 10000 + 25000 + 13600 - 3000);
      expect(outubro.lancamentos, 5);
      expect(outubro.situacao, SituacaoFatura.paga);
      expect(lista[1].situacao, SituacaoFatura.aberta);
      expect(lista[0].situacao, SituacaoFatura.futura);
    });

    test('Inter: o estorno da Mochila passa das compras e vira crédito', () async {
      final lista = await faturas('Inter');
      final porMes = {for (final f in lista) mesIso(f.mes): f};
      expect(porMes['2026-10']!.situacao, SituacaoFatura.fechada);
      final novembro = porMes['2026-11']!;
      expect((novembro.compras, novembro.estornos), (4490, 6000));
      expect((novembro.total, novembro.creditoSeguinte), (0, 1510));
      final dezembro = porMes['2026-12']!;
      expect((dezembro.creditoAnterior, dezembro.total), (1510, 4490 - 1510));
    });

    test('atualiza sozinho quando um lançamento muda', () async {
      final nubank = await cartao('Nubank');
      final fluxo = db.faturasDao.observar(nubank.id);
      final antes = await fluxo.first;
      final padaria = await (db.select(db.lancamentos)..where((l) => l.descricao.equals('Padaria')))
          .getSingle();
      await (db.update(db.lancamentos)..where((l) => l.id.equals(padaria.id))).write(
        LancamentosCompanion(
          contaId: const Value(null),
          cartaoId: Value(nubank.id),
          mesFatura: const Value('2026-11'),
          mesReferencia: const Value('2026-11'),
        ),
      );
      final depois = await fluxo.first;
      int compras(List<MovimentoDaFatura> m) => m.firstWhere((x) => x.mes == '2026-11').compras;
      expect(compras(depois) - compras(antes), 1850);
    });
  });

  group('editar o cartão', () {
    Future<List<Lancamento>> doNubank() async {
      final nubank = await cartao('Nubank');
      return (db.select(db.lancamentos)
            ..where((l) => l.cartaoId.equals(nubank.id))
            ..orderBy([(l) => OrderingTerm(expression: l.id)]))
          .get();
    }

    test('mudar o fechamento recalcula a fatura dos lançamentos automáticos', () async {
      final nubank = await cartao('Nubank');
      // O Mercado (28/09) vai à mão para novembro e não pode mudar.
      final antes = await doNubank();
      final mercado = antes.firstWhere((l) => l.descricao == 'Mercado Atacadão');
      await (db.update(db.lancamentos)..where((l) => l.id.equals(mercado.id))).write(
        const LancamentosCompanion(
          mesFatura: Value('2026-11'),
          mesReferencia: Value('2026-11'),
          faturaManual: Value(1),
        ),
      );

      // Fechando dia 20 e vencendo dia 27, as compras de 15 e 18/09 voltam
      // para setembro; a de 25/09 (o fone) e o estorno de 02/10 continuam
      // em outubro.
      final mudaram = await db.cartoesDao.editar(
        nubank.id,
        nome: 'Nubank',
        diaFechamento: 20,
        diaVencimento: 27,
        contaPagamentoId: nubank.contaPagamentoId,
      );
      final depois = {for (final l in await doNubank()) l.id: l};
      String fatura(String nome, [int? parcela]) => depois.values
          .firstWhere((l) => l.descricao == nome && (parcela == null || l.parcelaAtual == parcela))
          .mesFatura!;

      expect(fatura('Mercado Atacadão'), '2026-11');
      expect([fatura('Fone Bluetooth', 1), fatura('Fone Bluetooth', 2), fatura('Fone Bluetooth', 3)], [
        '2026-10',
        '2026-11',
        '2026-12',
      ]);
      expect(fatura('Combustível'), '2026-09');
      expect(fatura('Restaurante'), '2026-09');
      expect(
        depois.values.firstWhere((l) => l.tipo == 'estorno').mesFatura,
        '2026-10',
      );
      // O mês de referência segue a fatura.
      expect(depois.values.every((l) => l.mesReferencia == l.mesFatura), isTrue);
      // Só o Combustível e o Restaurante mudaram.
      expect(mudaram, 2);
    });

    test('só trocar o nome não mexe em nenhum lançamento', () async {
      final nubank = await cartao('Nubank');
      final antes = [for (final l in await doNubank()) l.mesFatura];
      Future<List<String?>> faturasDepois() async => [
        for (final l in await (db.select(db.lancamentos)
              ..where((l) => l.cartaoId.equals(nubank.id))
              ..orderBy([(l) => OrderingTerm(expression: l.id)]))
            .get())
          l.mesFatura,
      ];
      final mudaram = await db.cartoesDao.editar(
        nubank.id,
        nome: 'Nu',
        diaFechamento: nubank.diaFechamento,
        diaVencimento: nubank.diaVencimento,
        contaPagamentoId: nubank.contaPagamentoId,
      );
      expect(mudaram, 0);
      expect(await faturasDepois(), antes);
    });
  });
}
