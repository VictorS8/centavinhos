import 'package:centavinhos/data/daos/cadastro_bloqueado.dart';
import 'package:centavinhos/data/daos/categorias_dao.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final hoje = DateTime(2026, 10, 12);

  Matcher bloqueado(String motivo) =>
      throwsA(isA<CadastroBloqueado>().having((e) => e.motivo, 'motivo', motivo));

  group('migração', () {
    test('banco da versão 1 ganha a coluna arquivada em tags e mantém as tags', () async {
      // Os bancos deste teste têm cada um a sua conexão; o aviso do Drift
      // sobre várias instâncias não se aplica.
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

      // Monta um banco igual ao da versão 1: o atual sem a coluna nova.
      final bruto = sqlite3.openInMemory();
      final atual = AppDatabase(NativeDatabase.opened(bruto, closeUnderlyingOnClose: false));
      await atual.tagsDao.criar('viagem');
      await atual.close();
      bruto.execute('ALTER TABLE tags DROP COLUMN arquivada');
      bruto.execute('PRAGMA user_version = 1');

      final migrado = AppDatabase(NativeDatabase.opened(bruto));
      addTearDown(migrado.close);
      final tags = await migrado.select(migrado.tags).get();
      expect(tags.map((t) => (t.nome, t.arquivada)), [('viagem', 0)]);
      final versao = await migrado.customSelect('PRAGMA user_version').getSingle();
      expect(versao.read<int>('user_version'), 2);
    });
  });

  group('contas', () {
    Future<int> criar(String nome, {String tipo = 'banco'}) => db.contasDao.criar(
      nome: nome,
      tipo: tipo,
      saldoInicialCentavos: 0,
      dataSaldoInicial: hoje,
    );

    test('cria e edita com saldo inicial e data', () async {
      final id = await db.contasDao.criar(
        nome: '  Inter ',
        tipo: 'banco',
        saldoInicialCentavos: -20000,
        dataSaldoInicial: DateTime(2026, 10, 1),
      );
      var conta = (await db.contasDao.observar().first).single.conta;
      expect((conta.nome, conta.saldoInicialCentavos, conta.dataSaldoInicial), (
        'Inter',
        -20000,
        '2026-10-01',
      ));

      await db.contasDao.editar(
        id,
        nome: 'Banco Inter',
        tipo: 'carteira',
        saldoInicialCentavos: 50000,
        dataSaldoInicial: DateTime(2026, 9, 30),
      );
      conta = (await db.contasDao.observar().first).single.conta;
      expect((conta.nome, conta.tipo, conta.saldoInicialCentavos, conta.dataSaldoInicial), (
        'Banco Inter',
        'carteira',
        50000,
        '2026-09-30',
      ));
    });

    test('lista as ativas primeiro, em ordem de nome sem ligar para acentos', () async {
      final zeta = await criar('Zeta');
      await criar('Ágora');
      await criar('banco');
      await db.contasDao.arquivar(zeta);
      await criar('Alfa');
      final nomes = (await db.contasDao.observar().first).map((c) => c.conta.nome);
      expect(nomes, ['Ágora', 'Alfa', 'banco', 'Zeta']);
    });

    test('conta nova não está em uso; com lançamento, transferência ou cartão, está', () async {
      final a = await criar('A');
      final b = await criar('B');
      final c = await criar('C');
      final d = await criar('D');
      expect(await db.contasDao.emUso(a), isFalse);

      await db.into(db.lancamentos).insert(
        LancamentosCompanion.insert(
          tipo: 'ganho',
          descricao: 'Salário',
          valorCentavos: 100,
          dataLancamento: '2026-10-12',
          contaId: Value(a),
          mesReferencia: '2026-10',
          criadoEm: '2026-10-12T10:00:00',
        ),
      );
      await db.into(db.transferencias).insert(
        TransferenciasCompanion.insert(
          valorCentavos: 100,
          contaOrigemId: d,
          contaDestinoId: b,
          data: '2026-10-12',
          criadoEm: '2026-10-12T10:00:00',
        ),
      );
      await db.cartoesDao.criar(
        nome: 'Nubank',
        diaFechamento: 5,
        diaVencimento: 12,
        contaPagamentoId: c,
      );

      final uso = {
        for (final item in await db.contasDao.observar().first) item.conta.nome: item.emUso,
      };
      expect(uso, {'A': true, 'B': true, 'C': true, 'D': true});
      final e = await criar('E');
      expect(await db.contasDao.emUso(e), isFalse);
    });

    test('exclui a conta nunca usada e arquiva a usada', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final nova = await criar('Reserva');
      await db.contasDao.excluir(nova);
      expect((await db.contasDao.observar().first).map((c) => c.conta.nome), isNot(contains('Reserva')));

      final carteira = (await db.contasDao.observar().first)
          .singleWhere((c) => c.conta.nome == 'Carteira');
      expect(carteira.emUso, isTrue);
      await expectLater(
        db.contasDao.excluir(carteira.conta.id),
        bloqueado('Esta conta já foi usada: ela só pode ser arquivada.'),
      );
      await db.contasDao.arquivar(carteira.conta.id);
      final depois = (await db.contasDao.observar().first).last.conta;
      expect((depois.nome, depois.arquivada), ('Carteira', 1));

      await db.contasDao.desarquivar(carteira.conta.id);
      expect((await db.contasDao.observar().first).every((c) => c.conta.arquivada == 0), isTrue);
    });

    test('não arquiva nem exclui a última conta ativa', () async {
      final unica = await criar('Carteira', tipo: 'carteira');
      final arquivada = await criar('Antiga');
      await db.contasDao.arquivar(arquivada);

      const motivo = 'É preciso ter ao menos uma conta ativa.';
      expect(await db.contasDao.motivoParaNaoTirar(unica), motivo);
      await expectLater(db.contasDao.arquivar(unica), bloqueado(motivo));
      await expectLater(db.contasDao.excluir(unica), bloqueado(motivo));
    });

    test('não arquiva a conta que paga um cartão ativo', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final contas = await db.contasDao.observar().first;
      final nubank = contas.singleWhere((c) => c.conta.nome == 'Nubank').conta.id;
      await expectLater(
        db.contasDao.arquivar(nubank),
        bloqueado('Troque antes a conta que paga o cartão Nubank.'),
      );

      // Com o cartão arquivado, a conta pode ser arquivada.
      final cartoes = await db.cartoesDao.observar().first;
      await db.cartoesDao.arquivar(cartoes.singleWhere((c) => c.cartao.nome == 'Nubank').cartao.id);
      expect(await db.contasDao.motivoParaNaoTirar(nubank), isNull);
      await db.contasDao.arquivar(nubank);
    });
  });

  group('cartões', () {
    late int nubank;
    late int inter;

    setUp(() async {
      nubank = await db.contasDao.criar(
        nome: 'Nubank',
        tipo: 'banco',
        saldoInicialCentavos: 0,
        dataSaldoInicial: hoje,
      );
      inter = await db.contasDao.criar(
        nome: 'Inter',
        tipo: 'banco',
        saldoInicialCentavos: 0,
        dataSaldoInicial: hoje,
      );
    });

    test('cria e edita fechamento, vencimento e conta de pagamento', () async {
      final id = await db.cartoesDao.criar(
        nome: 'Nubank',
        diaFechamento: 5,
        diaVencimento: 12,
        contaPagamentoId: nubank,
      );
      await db.cartoesDao.editar(
        id,
        nome: 'Nubank Ultravioleta',
        diaFechamento: 28,
        diaVencimento: 5,
        contaPagamentoId: inter,
      );
      final cartao = (await db.cartoesDao.observar().first).single;
      expect(
        (
          cartao.cartao.nome,
          cartao.cartao.diaFechamento,
          cartao.cartao.diaVencimento,
          cartao.cartao.contaPagamentoId,
          cartao.emUso,
        ),
        ('Nubank Ultravioleta', 28, 5, inter, false),
      );
    });

    test('exclui o cartão nunca usado', () async {
      final id = await db.cartoesDao.criar(
        nome: 'C6',
        diaFechamento: 1,
        diaVencimento: 10,
        contaPagamentoId: nubank,
      );
      await db.cartoesDao.excluir(id);
      expect(await db.cartoesDao.observar().first, isEmpty);
    });

    test('cartão usado só é arquivado', () async {
      final id = await db.cartoesDao.criar(
        nome: 'Nubank',
        diaFechamento: 5,
        diaVencimento: 12,
        contaPagamentoId: nubank,
      );
      await db.into(db.faturas).insert(
        FaturasCompanion.insert(cartaoId: id, mes: '2026-10', pagoEm: const Value('2026-10-11')),
      );
      expect(await db.cartoesDao.emUso(id), isTrue);
      await expectLater(
        db.cartoesDao.excluir(id),
        bloqueado('Este cartão já foi usado: ele só pode ser arquivado.'),
      );
      await db.cartoesDao.arquivar(id);
      expect((await db.cartoesDao.observar().first).single.cartao.arquivado, 1);
    });

    test('só desarquiva com a conta de pagamento ativa', () async {
      final id = await db.cartoesDao.criar(
        nome: 'Inter',
        diaFechamento: 8,
        diaVencimento: 15,
        contaPagamentoId: inter,
      );
      await db.cartoesDao.arquivar(id);
      await db.contasDao.arquivar(inter);

      const motivo = 'Desarquive antes a conta Inter, que paga este cartão.';
      expect(await db.cartoesDao.motivoParaNaoDesarquivar(id), motivo);
      await expectLater(db.cartoesDao.desarquivar(id), bloqueado(motivo));

      await db.contasDao.desarquivar(inter);
      await db.cartoesDao.desarquivar(id);
      expect((await db.cartoesDao.observar().first).single.cartao.arquivado, 0);
    });
  });

  group('categorias', () {
    Future<List<CategoriaComSubcategorias>> arvore(String tipo) async =>
        CategoriaComSubcategorias.montar(
          (await db.categoriasDao.observar().first).where((c) => c.categoria.tipo == tipo),
        );

    Future<CategoriaComSubcategorias> principal(String nome) async =>
        (await arvore('despesa')).singleWhere((c) => c.categoria.nome == nome);

    test('árvore em ordem de nome, com as subcategorias de cada uma', () async {
      final despesas = await arvore('despesa');
      expect(despesas.map((c) => c.categoria.nome), [
        'Alimentação',
        'Assinaturas',
        'Casa',
        'Compras',
        'Educação',
        'Lazer',
        'Outros',
        'Saúde',
        'Taxas',
        'Transporte',
      ]);
      final casa = despesas.singleWhere((c) => c.categoria.nome == 'Casa');
      expect(casa.subcategorias.map((s) => s.categoria.nome), [
        'Aluguel',
        'Contas de casa',
        'Limpeza',
        'Manutenção',
        'Mercado',
      ]);
      expect((await arvore('ganho')).map((c) => c.categoria.nome), [
        'Outros',
        'Reembolso',
        'Renda extra',
        'Rendimentos',
        'Salário',
      ]);
    });

    test('subcategoria herda o tipo da principal e tem um nível só', () async {
      final salario = (await arvore('ganho')).singleWhere((c) => c.categoria.nome == 'Salário');
      final id = await db.categoriasDao.criarSubcategoria(
        nome: '13º',
        principalId: salario.categoria.id,
      );
      final sub = (await arvore('ganho'))
          .singleWhere((c) => c.categoria.nome == 'Salário')
          .subcategorias
          .single
          .categoria;
      expect((sub.id, sub.tipo, sub.categoriaPaiId), (id, 'ganho', salario.categoria.id));

      expect(
        () => db.categoriasDao.criarSubcategoria(nome: 'Extra', principalId: id),
        throwsArgumentError,
      );
    });

    test('cria e renomeia', () async {
      final id = await db.categoriasDao.criar(nome: ' Pets ', tipo: 'despesa');
      await db.categoriasDao.renomear(id, 'Animais');
      expect((await principal('Animais')).categoria.id, id);
    });

    test('arquivar a principal leva as subcategorias; desarquivar traz de volta', () async {
      final casa = await principal('Casa');
      await db.categoriasDao.arquivar(casa.categoria.id);
      var depois = await principal('Casa');
      expect(depois.categoria.arquivada, 1);
      expect(depois.subcategorias.every((s) => s.categoria.arquivada == 1), isTrue);

      await db.categoriasDao.desarquivar(casa.categoria.id);
      depois = await principal('Casa');
      expect(depois.categoria.arquivada, 0);
      expect(depois.subcategorias.every((s) => s.categoria.arquivada == 0), isTrue);
    });

    test('desarquivar uma subcategoria traz a principal, mas não as irmãs', () async {
      final casa = await principal('Casa');
      await db.categoriasDao.arquivar(casa.categoria.id);
      final mercado = casa.subcategorias.singleWhere((s) => s.categoria.nome == 'Mercado');
      await db.categoriasDao.desarquivar(mercado.categoria.id);

      final depois = await principal('Casa');
      expect(depois.categoria.arquivada, 0);
      expect(
        {for (final s in depois.subcategorias) s.categoria.nome: s.categoria.arquivada},
        {'Aluguel': 1, 'Contas de casa': 1, 'Limpeza': 1, 'Manutenção': 1, 'Mercado': 0},
      );
    });

    test('uso: a principal conta como usada quando uma subcategoria foi usada', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final casa = await principal('Casa');
      expect(casa.principal.emUso, isFalse);
      expect(casa.emUso, isTrue);
      expect(await db.categoriasDao.emUso(casa.categoria.id), isTrue);
      expect(casa.subcategorias.where((s) => s.emUso).map((s) => s.categoria.nome), [
        'Aluguel',
        'Limpeza',
        'Mercado',
      ]);
      expect((await principal('Educação')).emUso, isFalse);
    });

    test('exclui a principal nunca usada junto com as subcategorias', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final educacao = await principal('Educação');
      await db.categoriasDao.excluir(educacao.categoria.id);
      final nomes = (await db.categoriasDao.observar().first).map((c) => c.categoria.nome);
      expect(nomes, isNot(contains('Educação')));
      expect(nomes, isNot(contains('Cursos')));
      expect(nomes, isNot(contains('Livros')));
    });

    test('não exclui categoria usada, nem a principal de uma subcategoria usada', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final casa = await principal('Casa');
      const motivo = 'Esta categoria já foi usada: ela só pode ser arquivada.';
      await expectLater(db.categoriasDao.excluir(casa.categoria.id), bloqueado(motivo));
      final mercado = casa.subcategorias.singleWhere((s) => s.categoria.nome == 'Mercado');
      await expectLater(db.categoriasDao.excluir(mercado.categoria.id), bloqueado(motivo));

      // Uma subcategoria nunca usada de uma principal usada pode sair.
      final manutencao = casa.subcategorias.singleWhere((s) => s.categoria.nome == 'Manutenção');
      await db.categoriasDao.excluir(manutencao.categoria.id);
      expect((await principal('Casa')).subcategorias, hasLength(4));
    });
  });

  group('tags', () {
    test('cria sem o #, renomeia e conta os lançamentos', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final id = await db.tagsDao.criar('#Mercado livre');
      await db.tagsDao.renomear(id, 'compras online');
      final tags = {
        for (final t in await db.tagsDao.observar().first) t.tag.nome: t.lancamentos,
      };
      expect(tags, {'compras online': 0, 'trabalho': 2, 'viagem': 0});
    });

    test('exclui a tag nunca usada e arquiva a usada', () async {
      await gerarDadosExemplo(db, hoje: hoje);
      final tags = await db.tagsDao.observar().first;
      final trabalho = tags.singleWhere((t) => t.tag.nome == 'trabalho').tag.id;
      final viagem = tags.singleWhere((t) => t.tag.nome == 'viagem').tag.id;

      await db.tagsDao.excluir(viagem);
      await expectLater(
        db.tagsDao.excluir(trabalho),
        bloqueado('Esta tag já foi usada: ela só pode ser arquivada.'),
      );
      await db.tagsDao.arquivar(trabalho);
      var depois = await db.tagsDao.observar().first;
      expect(depois.map((t) => (t.tag.nome, t.tag.arquivada)), [('trabalho', 1)]);

      await db.tagsDao.desarquivar(trabalho);
      depois = await db.tagsDao.observar().first;
      expect(depois.single.tag.arquivada, 0);
    });
  });

  test('apagarTudo também limpa as tags arquivadas', () async {
    await gerarDadosExemplo(db, hoje: hoje);
    final viagem = (await db.tagsDao.observar().first).last.tag.id;
    await db.tagsDao.arquivar(viagem);
    await db.apagarTudo();
    expect(await db.tagsDao.observar().first, isEmpty);
  });
}
