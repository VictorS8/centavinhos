import 'package:centavinhos/data/daos/exclusao_dao.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/domain/exclusao.dart';
import 'package:centavinhos/domain/mes.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12));
  });
  tearDown(() => db.close());

  Future<List<ItemDoMes>> doMes(String mes) => db.mesDao.observar(mes).first;

  ItemDoMes achar(List<ItemDoMes> itens, String nome) => itens.singleWhere((i) => i.nome == nome);

  Future<Lancamento> lancamento(String descricao, {int? parcela, String? data}) async {
    final todos = await (db.select(
      db.lancamentos,
    )..where((l) => l.descricao.equals(descricao))).get();
    return todos.singleWhere(
      (l) =>
          (parcela == null || l.parcelaAtual == parcela) &&
          (data == null || l.dataLancamento == data),
    );
  }

  /// Uma cópia de tudo que os lançamentos têm, para comparar depois de
  /// desfazer. Categorias e tags voltam com outro `rowid`, mas na mesma ordem
  /// dentro de cada lançamento, que é a que a tela usa.
  Future<String> retrato() async {
    const rowid = CustomExpression<int>('rowid');
    return [
      for (final l in await (db.select(
        db.lancamentos,
      )..orderBy([(l) => OrderingTerm(expression: l.id)])).get())
        l.toString(),
      for (final c
          in await (db.select(db.lancamentoCategorias)..orderBy([
                (c) => OrderingTerm(expression: c.lancamentoId),
                (_) => OrderingTerm(expression: rowid),
              ]))
              .get())
        c.toString(),
      for (final t
          in await (db.select(db.lancamentoTags)..orderBy([
                (t) => OrderingTerm(expression: t.lancamentoId),
                (_) => OrderingTerm(expression: rowid),
              ]))
              .get())
        t.toString(),
      for (final t in await db.select(db.transferencias).get()) t.toString(),
      for (final r in await db.select(db.recorrencias).get()) r.toString(),
    ].join('\n');
  }

  group('lista do mês', () {
    test('cartão conta pelo mês da fatura; conta, pela data', () async {
      final outubro = await doMes('2026-10');
      final nomes = [for (final i in outubro) i.nome];
      // Compras de setembro no cartão caem na fatura de outubro.
      expect(nomes, containsAll(['Mercado Atacadão', 'Fone Bluetooth (1/3)', 'Farmácia']));
      // A parcela 2 e o Netflix de outubro vão para a fatura de novembro.
      expect(nomes, isNot(contains('Fone Bluetooth (2/3)')));
      expect(nomes.where((n) => n == 'Netflix'), hasLength(1));
      expect(achar(outubro, 'Netflix').data, DateTime(2026, 9, 22));
      // Ganho e despesa em conta pela data, e a transferência do mês.
      expect(
        nomes,
        containsAll(['Salário', 'Aluguel', 'Padaria', 'Transferência Nubank para Inter']),
      );

      final novembro = await doMes('2026-11');
      expect([for (final i in novembro) i.nome], contains('Fone Bluetooth (2/3)'));
      expect([
        for (final i in novembro) i.nome,
      ], isNot(contains('Transferência Nubank para Inter')));
    });

    test('mais recente primeiro', () async {
      final datas = [for (final i in await doMes('2026-10')) i.data];
      for (var i = 1; i < datas.length; i++) {
        expect(datas[i].isAfter(datas[i - 1]), isFalse);
      }
    });

    test('categorias, cartão com vencimento, etiquetas e tipos', () async {
      final outubro = await doMes('2026-10');
      final mercado = achar(outubro, 'Mercado Atacadão');
      expect(mercado.categorias.map((c) => (c.rotulo, c.valorCentavos)), [
        ('Casa, Mercado', 30000),
        ('Casa, Limpeza', 11230),
      ]);
      expect(mercado.detalhe, 'Casa, Mercado · Nubank, vence 12/10');
      expect(achar(outubro, 'Farmácia').detalhe, 'Saúde, Remédios · Inter, vence 15/10');
      expect(achar(outubro, 'Padaria').detalhe, 'Alimentação, Lanches · Carteira');
      expect(achar(outubro, 'Salário').mensal, isTrue);
      expect(achar(outubro, 'Salário').valorNaLista, '+R\$ 4.000,00');
      expect(achar(outubro, 'Padaria').mensal, isFalse);
      expect(outubro.singleWhere((i) => i.tipo == 'estorno').valorNaLista, '−R\$ 30,00');
    });

    test('total de gastos do mês: despesas menos estornos', () async {
      expect(totalDeGastos(await doMes('2026-10')), 224270);
    });

    test('mês sem nada', () async {
      expect(await doMes('2030-01'), isEmpty);
    });

    test('atualiza sozinha quando um lançamento muda', () async {
      final lista = db.mesDao.observar('2026-10');
      final atualizacoes = <int>[];
      final assinatura = lista.listen((itens) => atualizacoes.add(itens.length));
      await pumpEventQueue();
      final padaria = await lancamento('Padaria');
      await db.exclusaoDao.excluir((transferencia: false, id: padaria.id), AlcanceExclusao.soEste);
      await pumpEventQueue();
      await assinatura.cancel();
      expect(atualizacoes.last, atualizacoes.first - 1);
    });
  });

  group('excluir e desfazer', () {
    test('lançamento sozinho sai com as categorias e as tags, e volta igual', () async {
      final antes = await retrato();
      final corrida = await lancamento('Corrida de aplicativo');
      final alvo = (transferencia: false, id: corrida.id);

      expect((await db.exclusaoDao.grupoDe(alvo)).tipo, TipoDeGrupo.nenhum);
      final excluidos = await db.exclusaoDao.excluir(alvo, AlcanceExclusao.soEste);
      expect(excluidos.quantidade, 1);
      expect(excluidos.categorias, hasLength(1));
      expect(excluidos.tags, hasLength(1));
      expect(
        await (db.select(db.lancamentoTags)..where((t) => t.lancamentoId.equals(corrida.id))).get(),
        isEmpty,
      );

      await db.exclusaoDao.restaurar(excluidos);
      expect(await retrato(), antes);
    });

    test('parcela: "este e os próximos" tira a 2 e a 3', () async {
      final antes = await retrato();
      final segunda = await lancamento('Fone Bluetooth', parcela: 2);
      final alvo = (transferencia: false, id: segunda.id);

      final grupo = await db.exclusaoDao.grupoDe(alvo);
      expect(grupo.tipo, TipoDeGrupo.parcelas);
      expect(grupo.membros, hasLength(3));

      final excluidos = await db.exclusaoDao.excluir(alvo, AlcanceExclusao.esteEOsProximos);
      expect(excluidos.lancamentos.map((l) => l.parcelaAtual), [2, 3]);
      expect(excluidos.recorrencia, isNull);
      final restantes = await (db.select(
        db.lancamentos,
      )..where((l) => l.descricao.equals('Fone Bluetooth'))).get();
      expect(restantes.map((l) => l.parcelaAtual), [1]);

      await db.exclusaoDao.restaurar(excluidos);
      expect(await retrato(), antes);
    });

    test('parcela: "todos" tira as três', () async {
      final primeira = await lancamento('Fone Bluetooth', parcela: 1);
      final excluidos = await db.exclusaoDao.excluir((
        transferencia: false,
        id: primeira.id,
      ), AlcanceExclusao.todos);
      expect(excluidos.quantidade, 3);
    });

    test('recorrência: "só este" não mexe na recorrência', () async {
      final aluguel = await lancamento('Aluguel', data: '2026-10-10');
      final excluidos = await db.exclusaoDao.excluir((
        transferencia: false,
        id: aluguel.id,
      ), AlcanceExclusao.soEste);
      expect(excluidos.recorrencia, isNull);
      final recorrencia = await (db.select(
        db.recorrencias,
      )..where((r) => r.id.equals(aluguel.recorrenciaId!))).getSingle();
      expect(recorrencia.dataFim, isNull);
      expect(recorrencia.ativa, 1);
    });

    test('recorrência: "este e os próximos" encerra no dia anterior, e desfazer reabre', () async {
      final antes = await retrato();
      final aluguel = await lancamento('Aluguel', data: '2026-10-10');
      final alvo = (transferencia: false, id: aluguel.id);
      expect((await db.exclusaoDao.grupoDe(alvo)).tipo, TipoDeGrupo.recorrencia);

      final excluidos = await db.exclusaoDao.excluir(alvo, AlcanceExclusao.esteEOsProximos);
      expect(excluidos.lancamentos.map((l) => l.dataLancamento), ['2026-10-10', '2026-11-10']);
      final recorrencia = await (db.select(
        db.recorrencias,
      )..where((r) => r.id.equals(aluguel.recorrenciaId!))).getSingle();
      expect(recorrencia.dataFim, '2026-10-09');
      expect(recorrencia.ativa, 1);

      await db.exclusaoDao.restaurar(excluidos);
      expect(await retrato(), antes);
    });

    test('recorrência: "todos" desliga a recorrência', () async {
      final salario = await lancamento('Salário', data: '2026-10-05');
      final excluidos = await db.exclusaoDao.excluir((
        transferencia: false,
        id: salario.id,
      ), AlcanceExclusao.todos);
      expect(excluidos.quantidade, 3);
      final recorrencia = await (db.select(
        db.recorrencias,
      )..where((r) => r.id.equals(salario.recorrenciaId!))).getSingle();
      expect(recorrencia.ativa, 0);
    });

    test('transferência sai e volta', () async {
      final antes = await retrato();
      final transferencia = await db.select(db.transferencias).getSingle();
      final AlvoExclusao alvo = (transferencia: true, id: transferencia.id);
      expect((await db.exclusaoDao.grupoDe(alvo)).tipo, TipoDeGrupo.nenhum);

      final excluidos = await db.exclusaoDao.excluir(alvo, AlcanceExclusao.soEste);
      expect(excluidos.transferencias, hasLength(1));
      expect(await db.select(db.transferencias).get(), isEmpty);

      await db.exclusaoDao.restaurar(excluidos);
      expect(await retrato(), antes);
    });
  });
}
