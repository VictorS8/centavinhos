import 'package:centavinhos/data/categorias_padrao.dart';
import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final hoje = DateTime(2026, 10, 12);

  Future<int> criarConta({int saldo = 0}) => db.into(db.contas).insert(
    ContasCompanion.insert(
      nome: 'Nubank',
      tipo: 'banco',
      saldoInicialCentavos: Value(saldo),
      dataSaldoInicial: '2026-10-12',
    ),
  );

  test('cria as doze tabelas', () async {
    final tabelas = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .map((linha) => linha.read<String>('name'))
        .get();
    expect(tabelas.toSet(), {
      'contas',
      'cartoes',
      'faturas',
      'categorias',
      'tags',
      'recorrencias',
      'lancamentos',
      'lancamento_categorias',
      'lancamento_tags',
      'transferencias',
      'configuracoes',
      'filtros',
    });
  });

  test('cria os índices do escopo', () async {
    final indices = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((linha) => linha.read<String>('name'))
        .get();
    expect(indices, containsAll(['idx_lanc_mes', 'idx_lanc_data', 'idx_transf_data']));
  });

  test('chaves estrangeiras ligadas', () async {
    final linha = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(linha.read<int>('foreign_keys'), 1);
  });

  test('categorias padrão: 10 de despesa, 5 de ganho e 25 subcategorias', () async {
    final todas = await db.select(db.categorias).get();
    final principais = todas.where((c) => c.categoriaPaiId == null);
    final subcategorias = todas.where((c) => c.categoriaPaiId != null);

    expect(principais.where((c) => c.tipo == 'despesa').length, 10);
    expect(principais.where((c) => c.tipo == 'ganho').length, 5);
    expect(subcategorias.length, 25);
    expect(
      subcategorias.length,
      categoriasPadrao.fold<int>(0, (soma, c) => soma + c.subcategorias.length),
    );

    final casa = principais.singleWhere((c) => c.nome == 'Casa');
    final daCasa = subcategorias.where((c) => c.categoriaPaiId == casa.id).map((c) => c.nome);
    expect(daCasa, ['Aluguel', 'Mercado', 'Limpeza', 'Contas de casa', 'Manutenção']);
    expect(subcategorias.every((c) => c.tipo == 'despesa'), isTrue);
  });

  test('configurações iniciais', () async {
    final configuracoes = await db.observarConfiguracoes().first;
    expect(configuracoes, {
      ChaveConfiguracao.temaCor: 'verde',
      ChaveConfiguracao.temaModo: 'sistema',
      ChaveConfiguracao.boasVindasConcluida: '0',
    });
  });

  test('lançamento com conta e cartão ao mesmo tempo é recusado', () async {
    final conta = await criarConta();
    final cartao = await db.into(db.cartoes).insert(
      CartoesCompanion.insert(
        nome: 'Nubank',
        diaFechamento: 5,
        diaVencimento: 12,
        contaPagamentoId: conta,
      ),
    );
    final lancamento = LancamentosCompanion.insert(
      tipo: 'despesa',
      descricao: 'Mercado',
      valorCentavos: 1000,
      dataLancamento: '2026-10-12',
      contaId: Value(conta),
      cartaoId: Value(cartao),
      mesReferencia: '2026-10',
      criadoEm: '2026-10-12T10:00:00',
    );
    await expectLater(db.into(db.lancamentos).insert(lancamento), throwsA(isA<SqliteException>()));
  });

  test('lançamento sem conta e sem cartão é recusado', () async {
    final lancamento = LancamentosCompanion.insert(
      tipo: 'despesa',
      descricao: 'Mercado',
      valorCentavos: 1000,
      dataLancamento: '2026-10-12',
      mesReferencia: '2026-10',
      criadoEm: '2026-10-12T10:00:00',
    );
    await expectLater(db.into(db.lancamentos).insert(lancamento), throwsA(isA<SqliteException>()));
  });

  test('estorno sem cartão é recusado', () async {
    final conta = await criarConta();
    final estorno = LancamentosCompanion.insert(
      tipo: 'estorno',
      descricao: 'Devolução',
      valorCentavos: 1000,
      dataLancamento: '2026-10-12',
      contaId: Value(conta),
      mesReferencia: '2026-10',
      criadoEm: '2026-10-12T10:00:00',
    );
    await expectLater(db.into(db.lancamentos).insert(estorno), throwsA(isA<SqliteException>()));
  });

  test('cartão com conta de pagamento inexistente é recusado', () async {
    final cartao = CartoesCompanion.insert(
      nome: 'Nubank',
      diaFechamento: 5,
      diaVencimento: 12,
      contaPagamentoId: 999,
    );
    await expectLater(db.into(db.cartoes).insert(cartao), throwsA(isA<SqliteException>()));
  });

  test('conta com saldo inicial negativo é gravada', () async {
    final id = await criarConta(saldo: -20000);
    final conta = await (db.select(db.contas)..where((c) => c.id.equals(id))).getSingle();
    expect(conta.saldoInicialCentavos, -20000);
  });

  group('boas-vindas', () {
    test('grava contas e cartões e marca como concluída', () async {
      await db.concluirBoasVindas(
        contas: const [
          NovaConta(nome: 'Carteira', tipo: 'carteira', saldoInicialCentavos: 40000),
          NovaConta(nome: 'Inter', tipo: 'banco', saldoInicialCentavos: -20000),
        ],
        cartoes: const [
          NovoCartao(nome: 'Inter', diaFechamento: 28, diaVencimento: 5, indiceContaPagamento: 1),
        ],
        hoje: hoje,
      );

      final contas = await db.select(db.contas).get();
      expect(contas.map((c) => (c.nome, c.tipo, c.saldoInicialCentavos, c.dataSaldoInicial)), [
        ('Carteira', 'carteira', 40000, '2026-10-12'),
        ('Inter', 'banco', -20000, '2026-10-12'),
      ]);

      final cartao = await db.select(db.cartoes).getSingle();
      expect(cartao.contaPagamentoId, contas[1].id);
      expect((cartao.diaFechamento, cartao.diaVencimento), (28, 5));

      final configuracoes = await db.observarConfiguracoes().first;
      expect(configuracoes[ChaveConfiguracao.boasVindasConcluida], '1');
    });

    test('sem contas não grava nada', () {
      expect(
        () => db.concluirBoasVindas(contas: const [], hoje: hoje),
        throwsArgumentError,
      );
    });
  });

  group('dados de exemplo', () {
    test('geram um cenário válido e concluem as boas-vindas', () async {
      await gerarDadosExemplo(db, hoje: hoje);

      expect(await db.select(db.contas).get(), hasLength(3));
      expect(await db.select(db.cartoes).get(), hasLength(2));
      final lancamentos = await db.select(db.lancamentos).get();
      expect(lancamentos, isNotEmpty);
      expect(lancamentos.where((l) => l.tipo == 'estorno'), hasLength(1));

      // A soma das categorias bate com o valor de cada lançamento.
      final partes = await db.select(db.lancamentoCategorias).get();
      for (final lancamento in lancamentos) {
        final soma = partes
            .where((p) => p.lancamentoId == lancamento.id)
            .fold<int>(0, (total, p) => total + p.valorCentavos);
        expect(soma, lancamento.valorCentavos, reason: lancamento.descricao);
      }

      // As parcelas do fone caem em três faturas seguidas.
      final fone = lancamentos.where((l) => l.grupoParcelamento != null).toList();
      expect(fone.map((l) => l.mesFatura), ['2026-10', '2026-11', '2026-12']);

      final configuracoes = await db.observarConfiguracoes().first;
      expect(configuracoes[ChaveConfiguracao.boasVindasConcluida], '1');
    });

    test('apagarTudo volta ao banco recém-criado', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      await db.apagarTudo();

      expect(await db.select(db.contas).get(), isEmpty);
      expect(await db.select(db.lancamentos).get(), isEmpty);
      expect(await db.select(db.categorias).get(), hasLength(15 + 25));
      final configuracoes = await db.observarConfiguracoes().first;
      expect(configuracoes[ChaveConfiguracao.boasVindasConcluida], '0');
    });
  });
}
