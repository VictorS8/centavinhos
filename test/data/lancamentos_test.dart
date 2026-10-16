import 'package:centavinhos/data/daos/lancamentos_dao.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
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
    });
  });
}
