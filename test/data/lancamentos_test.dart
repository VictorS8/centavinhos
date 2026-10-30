import 'package:centavinhos/data/daos/lancamentos_dao.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/domain/datas.dart';
import 'package:centavinhos/domain/exclusao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LancamentosDao dao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.lancamentosDao;
    await gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12));
  });
  tearDown(() => db.close());

  Future<int> idDaConta(String nome) async =>
      (await (db.select(db.contas)..where((c) => c.nome.equals(nome))).getSingle()).id;

  Future<int> idDoCartao(String nome) async =>
      (await (db.select(db.cartoes)..where((c) => c.nome.equals(nome))).getSingle()).id;

  Future<int> idDaCategoria(String nome, {String? principal}) async {
    final todas = await db.select(db.categorias).get();
    final pai = principal == null ? null : todas.firstWhere((c) => c.nome == principal).id;
    return todas.firstWhere((c) => c.nome == nome && c.categoriaPaiId == pai).id;
  }

  Future<List<String>> nomesDasTags() async =>
      (await db.select(db.tags).get()).map((t) => t.nome).toList();

  group('salvar', () {
    test('despesa no cartão com duas categorias, tag nova e observação', () async {
      final nubank = await idDoCartao('Nubank');
      final mercado = await idDaCategoria('Mercado', principal: 'Casa');
      final limpeza = await idDaCategoria('Limpeza', principal: 'Casa');

      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: '  Mercado   Atacadão ',
          valorCentavos: 10000,
          data: DateTime(2026, 10, 6),
          cartaoId: nubank,
          mesFatura: '2026-11',
          categorias: [
            (categoriaId: mercado, valorCentavos: 8000),
            (categoriaId: limpeza, valorCentavos: 2000),
          ],
          tags: ['#casa nova', 'trabalho'],
          observacao: ' compra do mês ',
        ),
      );

      final salvo = await dao.carregar(id);
      final l = salvo.lancamento;
      expect(l.descricao, 'Mercado Atacadão');
      expect(l.dataLancamento, '2026-10-06');
      expect((l.cartaoId, l.contaId), (nubank, null));
      expect((l.mesFatura, l.mesReferencia, l.faturaManual), ('2026-11', '2026-11', 0));
      expect(l.observacao, 'compra do mês');
      expect(l.criadoEm, isNotEmpty);
      expect(salvo.categorias, [
        (categoriaId: mercado, valorCentavos: 8000),
        (categoriaId: limpeza, valorCentavos: 2000),
      ]);
      // A tag nova é criada sem o "#"; a que já existe é reaproveitada.
      expect(salvo.tags, ['casa nova', 'trabalho']);
      expect((await nomesDasTags()).where((t) => t == 'trabalho'), hasLength(1));
    });

    test('ganho na conta conta pelo mês da data, sem fatura', () async {
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'ganho',
          descricao: 'Freela',
          valorCentavos: 50000,
          data: DateTime(2026, 10, 30),
          contaId: await idDaConta('Inter'),
          categorias: [(categoriaId: await idDaCategoria('Renda extra'), valorCentavos: 50000)],
        ),
      );
      final l = (await dao.carregar(id)).lancamento;
      expect((l.tipo, l.mesFatura, l.mesReferencia, l.observacao), ('ganho', null, '2026-10', null));
    });

    test('fatura trocada à mão fica marcada', () async {
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Livro',
          valorCentavos: 5990,
          data: DateTime(2026, 10, 6),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-12',
          faturaManual: true,
          categorias: [(categoriaId: await idDaCategoria('Livros', principal: 'Educação'), valorCentavos: 5990)],
        ),
      );
      final l = (await dao.carregar(id)).lancamento;
      expect((l.mesFatura, l.mesReferencia, l.faturaManual), ('2026-12', '2026-12', 1));
    });

    test('categoria principal com subcategorias pode ser escolhida direto', () async {
      final casa = await idDaCategoria('Casa');
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Luminária',
          valorCentavos: 8000,
          data: DateTime(2026, 10, 12),
          contaId: await idDaConta('Carteira'),
          categorias: [(categoriaId: casa, valorCentavos: 8000)],
        ),
      );
      expect((await dao.carregar(id)).categorias.single.categoriaId, casa);
    });

    test('tag arquivada digitada é reaproveitada e desarquivada', () async {
      final viagem = await (db.select(db.tags)..where((t) => t.nome.equals('viagem'))).getSingle();
      await db.tagsDao.arquivar(viagem.id);

      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Hotel',
          valorCentavos: 30000,
          data: DateTime(2026, 10, 12),
          contaId: await idDaConta('Nubank'),
          categorias: [(categoriaId: await idDaCategoria('Viagens', principal: 'Lazer'), valorCentavos: 30000)],
          tags: ['Viagem'],
        ),
      );

      expect((await dao.carregar(id)).tags, ['viagem']);
      final depois = await (db.select(db.tags)..where((t) => t.id.equals(viagem.id))).getSingle();
      expect(depois.arquivada, 0);
      expect((await nomesDasTags()).where((t) => t.toLowerCase() == 'viagem'), hasLength(1));
    });

    test('editar troca os dados, as categorias e as tags e mantém o resto', () async {
      final carteira = await idDaConta('Carteira');
      final lanches = await idDaCategoria('Lanches', principal: 'Alimentação');
      final delivery = await idDaCategoria('Delivery', principal: 'Alimentação');
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Lanche',
          valorCentavos: 2500,
          data: DateTime(2026, 10, 12),
          contaId: carteira,
          categorias: [(categoriaId: lanches, valorCentavos: 2500)],
          tags: ['trabalho'],
        ),
      );
      final antes = (await dao.carregar(id)).lancamento;

      await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Lanche e entrega',
          valorCentavos: 4000,
          data: DateTime(2026, 10, 11),
          contaId: carteira,
          categorias: [
            (categoriaId: lanches, valorCentavos: 2500),
            (categoriaId: delivery, valorCentavos: 1500),
          ],
        ),
        id: id,
      );

      final depois = await dao.carregar(id);
      expect(depois.lancamento.descricao, 'Lanche e entrega');
      expect(depois.lancamento.valorCentavos, 4000);
      expect(depois.lancamento.dataLancamento, '2026-10-11');
      expect(depois.lancamento.criadoEm, antes.criadoEm);
      expect(depois.categorias, hasLength(2));
      expect(depois.tags, isEmpty);
      final total = await db.select(db.lancamentos).get();
      expect(total.where((l) => l.descricao.startsWith('Lanche')), hasLength(1));
    });

    test('nunca grava soma de categorias diferente do valor nem cartão sem fatura', () async {
      final casa = await idDaCategoria('Casa');
      final quebrados = [
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'X',
          valorCentavos: 10000,
          data: DateTime(2026, 10, 12),
          contaId: await idDaConta('Carteira'),
          categorias: [(categoriaId: casa, valorCentavos: 9000)],
        ),
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'X',
          valorCentavos: 10000,
          data: DateTime(2026, 10, 12),
          cartaoId: await idDoCartao('Nubank'),
          categorias: [(categoriaId: casa, valorCentavos: 10000)],
        ),
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'X',
          valorCentavos: 10000,
          data: DateTime(2026, 10, 12),
          contaId: await idDaConta('Carteira'),
          categorias: const [],
        ),
      ];
      final antes = (await db.select(db.lancamentos).get()).length;
      for (final dados in quebrados) {
        expect(() => dao.salvar(dados), throwsArgumentError);
      }
      expect(await db.select(db.lancamentos).get(), hasLength(antes));
    });
  });

  group('nome conhecido', () {
    test('nomes usados por tipo, do mais recente ao mais antigo, sem repetir', () async {
      final despesas = await dao.observarNomes('despesa').first;
      expect(despesas.first, 'Corrida de aplicativo');
      expect(despesas.where((n) => n == 'Netflix'), hasLength(1));
      expect(despesas, isNot(contains('Salário')));
      expect(await dao.observarNomes('ganho').first, ['Salário']);
    });

    test('repete da última vez as categorias, o cartão e as tags', () async {
      final p = (await dao.ultimoComNome('Mercado Atacadão', 'despesa'))!;
      expect(p.cartaoId, await idDoCartao('Nubank'));
      expect(p.contaId, isNull);
      expect(p.categoriaIds, [
        await idDaCategoria('Mercado', principal: 'Casa'),
        await idDaCategoria('Limpeza', principal: 'Casa'),
      ]);
      expect(p.recorrente, isFalse);

      final corrida = (await dao.ultimoComNome('Corrida de aplicativo', 'despesa'))!;
      expect(corrida.contaId, await idDaConta('Nubank'));
      expect(corrida.tags, ['trabalho']);

      final netflix = (await dao.ultimoComNome('Netflix', 'despesa'))!;
      expect(netflix.recorrente, isTrue);
    });

    test('usa a vez mais recente', () async {
      await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Mercado Atacadão',
          valorCentavos: 5000,
          data: DateTime(2026, 9, 1),
          contaId: await idDaConta('Carteira'),
          categorias: [(categoriaId: await idDaCategoria('Mercado', principal: 'Casa'), valorCentavos: 5000)],
        ),
      );
      final p = (await dao.ultimoComNome('Mercado Atacadão', 'despesa'))!;
      expect((p.contaId, p.cartaoId), (await idDaConta('Carteira'), null));
      expect(p.categoriaIds, hasLength(1));
    });

    test('deixa de fora o que foi arquivado', () async {
      await db.cartoesDao.arquivar(await idDoCartao('Nubank'));
      await db.categoriasDao.arquivar(await idDaCategoria('Limpeza', principal: 'Casa'));
      final p = (await dao.ultimoComNome('Mercado Atacadão', 'despesa'))!;
      expect(p.cartaoId, isNull);
      expect(p.categoriaIds, [await idDaCategoria('Mercado', principal: 'Casa')]);

      final trabalho = await (db.select(db.tags)..where((t) => t.nome.equals('trabalho'))).getSingle();
      await db.tagsDao.arquivar(trabalho.id);
      expect((await dao.ultimoComNome('Corrida de aplicativo', 'despesa'))!.tags, isEmpty);
    });

    test('nome nunca usado no tipo não preenche nada', () async {
      expect(await dao.ultimoComNome('Salário', 'despesa'), isNull);
      expect(await dao.ultimoComNome('Nunca visto', 'despesa'), isNull);
    });
  });

  group('compra parcelada', () {
    Future<List<Lancamento>> parcelasDe(int primeiraId) async {
      final primeira = await (db.select(db.lancamentos)..where((l) => l.id.equals(primeiraId)))
          .getSingle();
      return (db.select(db.lancamentos)
            ..where((l) => l.grupoParcelamento.equals(primeira.grupoParcelamento!))
            ..orderBy([(l) => OrderingTerm(expression: l.parcelaAtual)]))
          .get();
    }

    Future<List<ParteCategoria>> partesDe(int id) async => (await dao.carregar(id)).categorias;

    test('exemplo do escopo: R\$ 300 em 3x no dia 06/10, de novembro a janeiro', () async {
      final eletronicos = await idDaCategoria('Eletrônicos', principal: 'Compras');
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Fone',
          valorCentavos: 30000,
          data: DateTime(2026, 10, 6),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-11',
          parcelas: 3,
          categorias: [(categoriaId: eletronicos, valorCentavos: 30000)],
          tags: ['trabalho'],
          observacao: 'presente',
        ),
      );

      final parcelas = await parcelasDe(id);
      expect(parcelas.first.id, id);
      expect(parcelas.map((l) => l.descricao), everyElement('Fone'));
      expect(parcelas.map((l) => (l.parcelaAtual, l.totalParcelas)), [(1, 3), (2, 3), (3, 3)]);
      expect(parcelas.map((l) => l.valorCentavos), [10000, 10000, 10000]);
      expect(parcelas.map((l) => l.mesFatura), ['2026-11', '2026-12', '2027-01']);
      expect(parcelas.map((l) => l.mesReferencia), ['2026-11', '2026-12', '2027-01']);
      // Todas guardam a data da compra; o grupo é o id da primeira.
      expect(parcelas.map((l) => l.dataLancamento), everyElement('2026-10-06'));
      expect(parcelas.map((l) => l.grupoParcelamento), everyElement('$id'));
      expect(parcelas.map((l) => l.observacao), everyElement('presente'));
      for (final parcela in parcelas) {
        expect((await dao.carregar(parcela.id)).tags, ['trabalho']);
      }
    });

    test('centavos que sobram e duas categorias: as somas batem em cada parcela', () async {
      final mercado = await idDaCategoria('Mercado', principal: 'Casa');
      final limpeza = await idDaCategoria('Limpeza', principal: 'Casa');
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Compra grande',
          valorCentavos: 10001,
          data: DateTime(2026, 10, 1),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-10',
          parcelas: 3,
          categorias: [
            (categoriaId: mercado, valorCentavos: 8000),
            (categoriaId: limpeza, valorCentavos: 2001),
          ],
        ),
      );
      final parcelas = await parcelasDe(id);
      expect(parcelas.map((l) => l.valorCentavos), [3335, 3333, 3333]);
      var somaMercado = 0;
      for (final parcela in parcelas) {
        final partes = await partesDe(parcela.id);
        expect(partes.fold(0, (t, p) => t + p.valorCentavos), parcela.valorCentavos);
        somaMercado += partes.firstWhere((p) => p.categoriaId == mercado).valorCentavos;
      }
      expect(somaMercado, 8000);
    });

    test('fatura trocada à mão vale para a primeira, e todas ficam marcadas', () async {
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Tênis',
          valorCentavos: 20000,
          data: DateTime(2026, 10, 6),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-12',
          faturaManual: true,
          parcelas: 2,
          categorias: [(categoriaId: await idDaCategoria('Roupas', principal: 'Compras'), valorCentavos: 20000)],
        ),
      );
      final parcelas = await parcelasDe(id);
      expect(parcelas.map((l) => l.mesFatura), ['2026-12', '2027-01']);
      expect(parcelas.map((l) => l.faturaManual), [1, 1]);
    });

    test('nome conhecido repete o número de parcelas', () async {
      final p = (await dao.ultimoComNome('Fone Bluetooth', 'despesa'))!;
      expect(p.parcelas, 3);
      expect((await dao.ultimoComNome('Padaria', 'despesa'))!.parcelas, isNull);
    });

    test('só em despesa no cartão, de 2 a 48 e ao menos 1 centavo por parcela', () async {
      final casa = await idDaCategoria('Casa');
      DadosLancamento dados({
        String tipo = 'despesa',
        int valor = 10000,
        int parcelas = 3,
        bool noCartao = true,
        required int? conta,
        required int cartao,
      }) => DadosLancamento(
        tipo: tipo,
        descricao: 'X',
        valorCentavos: valor,
        data: DateTime(2026, 10, 12),
        contaId: noCartao ? null : conta,
        cartaoId: noCartao ? cartao : null,
        mesFatura: noCartao ? '2026-11' : null,
        parcelas: parcelas,
        categorias: [(categoriaId: casa, valorCentavos: valor)],
      );
      final conta = await idDaConta('Carteira');
      final cartao = await idDoCartao('Nubank');
      final antes = (await db.select(db.lancamentos).get()).length;
      for (final quebrado in [
        dados(noCartao: false, conta: conta, cartao: cartao),
        dados(tipo: 'estorno', conta: conta, cartao: cartao),
        dados(parcelas: 1, conta: conta, cartao: cartao),
        dados(parcelas: 49, conta: conta, cartao: cartao),
        dados(valor: 2, parcelas: 3, conta: conta, cartao: cartao),
      ]) {
        expect(() => dao.salvar(quebrado), throwsArgumentError);
      }
      // Na edição, o número de parcelas não muda.
      final padaria = await (db.select(db.lancamentos)..where((l) => l.descricao.equals('Padaria')))
          .getSingle();
      expect(
        () => dao.salvar(dados(conta: conta, cartao: cartao), id: padaria.id),
        throwsArgumentError,
      );
      expect(await db.select(db.lancamentos).get(), hasLength(antes));
    });
  });

  group('editar parcelas', () {
    late List<Lancamento> fone;
    late int eletronicos;

    setUp(() async {
      fone = await (db.select(db.lancamentos)
            ..where((l) => l.descricao.equals('Fone Bluetooth'))
            ..orderBy([(l) => OrderingTerm(expression: l.parcelaAtual)]))
          .get();
      eletronicos = await idDaCategoria('Eletrônicos', principal: 'Compras');
    });

    /// A parcela 2 do fone (fatura de novembro) editada: novo nome e novo
    /// valor; com [mesFatura], a fatura trocada.
    DadosLancamento edicao({String? mesFatura, bool manual = false}) => DadosLancamento(
      tipo: 'despesa',
      descricao: 'Fone de ouvido',
      valorCentavos: 12000,
      data: lerDataIso(fone[1].dataLancamento),
      cartaoId: fone[1].cartaoId,
      mesFatura: mesFatura ?? fone[1].mesFatura,
      faturaManual: manual,
      categorias: [(categoriaId: eletronicos, valorCentavos: 12000)],
    );

    Future<List<Lancamento>> depois() => (db.select(db.lancamentos)
          ..where((l) => l.grupoParcelamento.equals(fone.first.grupoParcelamento!))
          ..orderBy([(l) => OrderingTerm(expression: l.parcelaAtual)]))
        .get();

    test('"só este" muda só a parcela aberta', () async {
      await dao.salvar(edicao(), id: fone[1].id);
      final lista = await depois();
      expect(lista.map((l) => l.descricao), ['Fone Bluetooth', 'Fone de ouvido', 'Fone Bluetooth']);
      expect(lista.map((l) => l.valorCentavos), [10000, 12000, 10000]);
      expect(lista.map((l) => l.mesFatura), ['2026-10', '2026-11', '2026-12']);
      // Parcela, total e grupo ficam como estavam.
      expect(lista.map((l) => l.parcelaAtual), [1, 2, 3]);
    });

    test('"este e os próximos" muda a 2 e a 3', () async {
      await dao.salvar(edicao(), id: fone[1].id, alcance: AlcanceExclusao.esteEOsProximos);
      final lista = await depois();
      expect(lista.map((l) => l.descricao), ['Fone Bluetooth', 'Fone de ouvido', 'Fone de ouvido']);
      expect(lista.map((l) => l.valorCentavos), [10000, 12000, 12000]);
      expect((await dao.carregar(lista[2].id)).categorias, [
        (categoriaId: eletronicos, valorCentavos: 12000),
      ]);
    });

    test('"todos" muda as três, e a fatura trocada leva as outras junto', () async {
      await dao.salvar(
        edicao(mesFatura: '2027-01', manual: true),
        id: fone[1].id,
        alcance: AlcanceExclusao.todos,
      );
      final lista = await depois();
      expect(lista.map((l) => l.descricao), everyElement('Fone de ouvido'));
      // A 2 foi para janeiro; a 1 e a 3 mantêm a distância dela.
      expect(lista.map((l) => l.mesFatura), ['2026-12', '2027-01', '2027-02']);
      expect(lista.map((l) => l.mesReferencia), ['2026-12', '2027-01', '2027-02']);
      expect(lista.map((l) => l.faturaManual), [1, 1, 1]);
    });
  });

  group('estorno', () {
    test('grava no cartão, com categoria, e abre para editar', () async {
      final restaurantes = await idDaCategoria('Restaurantes', principal: 'Alimentação');
      final id = await dao.salvar(
        DadosLancamento(
          tipo: 'estorno',
          descricao: 'Jantar cancelado',
          valorCentavos: 5000,
          data: DateTime(2026, 10, 6),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-11',
          categorias: [(categoriaId: restaurantes, valorCentavos: 5000)],
        ),
      );
      final salvo = await dao.carregar(id);
      expect(salvo.lancamento.tipo, 'estorno');
      expect((salvo.lancamento.mesFatura, salvo.lancamento.mesReferencia), ('2026-11', '2026-11'));
      expect(salvo.categorias, [(categoriaId: restaurantes, valorCentavos: 5000)]);

      // Editar pode desligar o estorno: vira despesa.
      await dao.salvar(
        DadosLancamento(
          tipo: 'despesa',
          descricao: 'Jantar',
          valorCentavos: 5000,
          data: DateTime(2026, 10, 6),
          cartaoId: await idDoCartao('Nubank'),
          mesFatura: '2026-11',
          categorias: [(categoriaId: restaurantes, valorCentavos: 5000)],
        ),
        id: id,
      );
      expect((await dao.carregar(id)).lancamento.tipo, 'despesa');
    });

    test('nunca numa conta', () async {
      expect(
        () => dao.salvar(
          DadosLancamento(
            tipo: 'estorno',
            descricao: 'X',
            valorCentavos: 5000,
            data: DateTime(2026, 10, 6),
            contaId: 1,
            categorias: const [(categoriaId: 1, valorCentavos: 5000)],
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('exemplos', () {
    test('o gerador usa a regra da fatura: compra no fechamento vai para a seguinte', () async {
      // Mercado em 28/09 no Nubank (fecha 5): fatura de outubro.
      final mercado = await (db.select(db.lancamentos)
            ..where((l) => l.descricao.equals('Mercado Atacadão')))
          .getSingle();
      expect(mercado.mesFatura, '2026-10');
      final fone = await (db.select(db.lancamentos)
            ..where((l) => l.descricao.equals('Fone Bluetooth'))
            ..orderBy([(l) => OrderingTerm(expression: l.parcelaAtual)]))
          .get();
      expect(fone.map((l) => l.mesFatura), ['2026-10', '2026-11', '2026-12']);
      // O grupo das parcelas é o id da primeira, como no app.
      expect(fone.map((l) => l.grupoParcelamento), everyElement('${fone.first.id}'));
    });
  });
}
