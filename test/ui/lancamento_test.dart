import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/casca_principal.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:centavinhos/ui/lancamento/janela_lancamento.dart';
import 'package:centavinhos/ui/lancamento/seletor_categorias.dart';
import 'package:centavinhos/ui/widgets/campo_valor.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('pt_BR'));
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Deixa o banco responder (ele roda fora do relógio falso dos testes).
  Future<void> esperarBanco(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }

  /// Abre o app com os dados de exemplo de 12/10/2026 e a janela de novo
  /// lançamento, pelo Ctrl+N. [antes] muda o banco antes de abrir o app.
  Future<void> abrir(WidgetTester tester, {Future<void> Function()? antes}) async {
    await tester.runAsync(() async {
      await gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12));
      await antes?.call();
    });
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bancoProvider.overrideWithValue(db),
          hojeProvider.overrideWithValue(DateTime(2026, 10, 12)),
        ],
        child: const CentavinhosApp(),
      ),
    );
    await esperarBanco(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    // A janela só pede os dados ao aparecer; a segunda espera deixa o banco
    // responder.
    await esperarBanco(tester);
    await esperarBanco(tester);
  }

  /// Um teste de tela que sempre desmonta o app no fim, mesmo quando falha.
  /// Sem isso, fechar o banco esperaria pelos fluxos da tela e travaria.
  void testarTela(String descricao, Future<void> Function(WidgetTester tester) corpo) {
    testWidgets(descricao, (tester) async {
      try {
        await corpo(tester);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(Duration.zero);
      }
    });
  }

  Finder campo(String rotulo) => find.widgetWithText(TextField, rotulo);

  EditableText editavel(WidgetTester tester, Finder alvo) =>
      tester.widget<EditableText>(find.descendant(of: alvo, matching: find.byType(EditableText)));

  String texto(WidgetTester tester, Finder alvo) => editavel(tester, alvo).controller.text;

  bool comFoco(WidgetTester tester, Finder alvo) => editavel(tester, alvo).focusNode.hasFocus;

  /// Campos de valor de cada categoria, na ordem da tela.
  Finder valorDaCategoria(int posicao) => find
      .descendant(of: find.byType(SeletorCategorias), matching: find.byType(CampoValor))
      .at(posicao);

  /// Digita [teclas] uma a uma no campo com foco, passando pelos
  /// formatadores (o valor estilo caixa eletrônico depende disso).
  Future<void> teclar(WidgetTester tester, Finder alvo, String teclas) async {
    final campoEditavel = find.descendant(of: alvo, matching: find.byType(EditableText));
    for (final tecla in teclas.split('')) {
      final atual = tester.widget<EditableText>(campoEditavel).controller.text;
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '$atual$tecla',
          selection: TextSelection.collapsed(offset: atual.length + 1),
        ),
      );
      await tester.pump();
    }
  }

  /// Rola a janela até [alvo] e toca nele.
  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  /// Toca no campo e digita, como no teclado.
  Future<void> digitar(WidgetTester tester, Finder alvo, String teclas) async {
    await tocar(tester, alvo);
    await teclar(tester, alvo, teclas);
  }

  Future<void> tab(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }

  /// Enter num campo de texto.
  Future<void> enter(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await esperarBanco(tester);
  }

  /// Escolhe [opcao] num menu (Conta ou cartão, Fatura) com o mouse.
  Future<void> escolherNoMenu(WidgetTester tester, String rotulo, String opcao) async {
    await tocar(tester, campo(rotulo));
    await tocar(tester, find.widgetWithText(MenuItemButton, opcao).last);
  }

  /// Busca e escolhe a categoria com Enter.
  Future<void> escolherCategoria(WidgetTester tester, String busca) async {
    final alvo = find.byKey(const ValueKey('busca'));
    final rotulo = find.descendant(of: alvo, matching: find.byType(TextField));
    await digitar(tester, rotulo, busca);
    await tester.pumpAndSettle();
    await enter(tester);
  }

  FilledButton salvar(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'));

  Future<List<Lancamento>> lancamentosCom(WidgetTester tester, String nome) async =>
      (await tester.runAsync(
        () => (db.select(db.lancamentos)..where((l) => l.descricao.equals(nome))).get(),
      ))!;

  group('janela', () {
    testarTela('Ctrl+N abre com o foco no nome, Salvar travado e Esc fecha', (tester) async {
      await abrir(tester);
      expect(find.text('Novo lançamento'), findsOneWidget);
      expect(comFoco(tester, campo('Nome')), isTrue);
      expect(texto(tester, campo('Valor')), 'R\$ 0,00');
      expect(texto(tester, campo('Recorrência')), 'Única');
      expect(texto(tester, campo('Data')), '12/10/2026');
      expect(find.text('Dê um nome ao lançamento.'), findsOneWidget);
      expect(salvar(tester).onPressed, isNull);
      // Despesa é o padrão e a transferência ainda não está ativa.
      final tipo = tester.widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>));
      expect(tipo.selected, {'despesa'});
      expect(tipo.segments.last.enabled, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsNothing);
    });

    testarTela('Ctrl+N com a janela aberta não abre outra', (tester) async {
      await abrir(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsOneWidget);
    });

    testarTela('travas do Salvar, na ordem dos campos', (tester) async {
      await abrir(tester);
      await tester.enterText(campo('Nome'), 'Padaria do bairro');
      await tester.pump();
      expect(find.text('Digite o valor.'), findsOneWidget);
      await digitar(tester, campo('Valor'), '1850');
      expect(find.text('Escolha uma categoria.'), findsOneWidget);
      await escolherCategoria(tester, 'lanch');
      expect(find.text('Alimentação, Lanches'), findsOneWidget);
      expect(find.text('Escolha a conta ou o cartão.'), findsOneWidget);
      await escolherNoMenu(tester, 'Conta ou cartão', 'Carteira');
      await tester.enterText(campo('Data'), '31/02');
      await tester.pump();
      expect(find.text('Data inválida. Use dd/mm ou dd/mm/aaaa.'), findsOneWidget);
      expect(salvar(tester).onPressed, isNull);
      await tester.enterText(campo('Data'), '11/10');
      await tester.pump();
      expect(salvar(tester).onPressed, isNotNull);
    });
  });

  group('teclado', () {
    testarTela('ordem do Tab e Enter no último campo salva', (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'Padoca');
      await tab(tester);
      expect(comFoco(tester, campo('Valor')), isTrue);
      await teclar(tester, campo('Valor'), '1850');
      await tab(tester);
      expect(comFoco(tester, campo('Recorrência')), isTrue);
      await tab(tester);
      expect(comFoco(tester, campo('Categoria')), isTrue);
      await teclar(tester, campo('Categoria'), 'lanch');
      await tester.pumpAndSettle();
      await enter(tester);
      // A categoria escolhida vira etiqueta e o campo fica livre.
      expect(find.text('Alimentação, Lanches'), findsOneWidget);
      expect(comFoco(tester, campo('Adicionar categoria')), isTrue);
      expect(texto(tester, campo('Adicionar categoria')), '');
      await tab(tester);
      expect(comFoco(tester, campo('Conta ou cartão')), isTrue);
      await teclar(tester, campo('Conta ou cartão'), 'cart');
      await tester.pumpAndSettle();
      await enter(tester);
      expect(texto(tester, campo('Conta ou cartão')), 'Carteira');
      await tab(tester);
      expect(comFoco(tester, campo('Data')), isTrue);

      await enter(tester);
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(find.text('Lançamento "Padoca" salvo.'), findsOneWidget);
      final salvos = await lancamentosCom(tester, 'Padoca');
      expect(salvos.map((l) => (l.tipo, l.valorCentavos, l.dataLancamento, l.mesReferencia)), [
        ('despesa', 1850, '2026-10-12', '2026-10'),
      ]);
    });

    testarTela('Enter com o Salvar travado não fecha nem tira o foco', (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'Padoca');
      await tab(tester);
      await enter(tester);
      expect(find.byType(JanelaLancamento), findsOneWidget);
      expect(comFoco(tester, campo('Valor')), isTrue);
    });

    testarTela('Enter e Esc no menu fechado salvam e cancelam', (tester) async {
      await abrir(tester);
      await tester.enterText(campo('Nome'), 'Padoca');
      await digitar(tester, campo('Valor'), '500');
      await escolherCategoria(tester, 'lanch');
      await escolherNoMenu(tester, 'Conta ou cartão', 'Carteira');
      expect(comFoco(tester, campo('Conta ou cartão')), isTrue);

      // Esc fecha a janela mesmo com o foco no menu.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(await lancamentosCom(tester, 'Padoca'), isEmpty);
    });

    testarTela('Enter no menu fechado salva', (tester) async {
      await abrir(tester);
      await tester.enterText(campo('Nome'), 'Padoca');
      await digitar(tester, campo('Valor'), '500');
      await escolherCategoria(tester, 'lanch');
      await escolherNoMenu(tester, 'Conta ou cartão', 'Carteira');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await esperarBanco(tester);
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(await lancamentosCom(tester, 'Padoca'), hasLength(1));
    });
  });

  group('nome conhecido', () {
    testarTela('sugestão preenche categorias, cartão e fatura, sem o valor', (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'atacad');
      await tester.pumpAndSettle();
      expect(find.text('Mercado Atacadão'), findsOneWidget);

      // Enter com a lista aberta escolhe a sugestão marcada.
      await enter(tester);
      expect(texto(tester, campo('Nome')), 'Mercado Atacadão');
      expect(find.text('Casa, Mercado'), findsOneWidget);
      expect(find.text('Casa, Limpeza'), findsOneWidget);
      expect(texto(tester, campo('Conta ou cartão')), 'Cartão Nubank');
      // 12/10 num cartão que fecha dia 5: fatura de novembro.
      expect(texto(tester, campo('Fatura')), 'Novembro/2026');
      expect(find.text('Calculada pela data; pode trocar'), findsOneWidget);
      expect(texto(tester, campo('Valor')), 'R\$ 0,00');
      expect(texto(tester, valorDaCategoria(0)), 'R\$ 0,00');
      expect(texto(tester, valorDaCategoria(1)), 'R\$ 0,00');
      expect(comFoco(tester, campo('Nome')), isTrue);

      // Distribui R$ 100,00 entre as duas.
      await digitar(tester, campo('Valor'), '10000');
      expect(find.text('Distribuído R\$ 0,00 de R\$ 100,00, faltam R\$ 100,00'), findsOneWidget);
      await digitar(tester, valorDaCategoria(0), '8000');
      expect(find.text('Distribuído R\$ 80,00 de R\$ 100,00, faltam R\$ 20,00'), findsOneWidget);
      expect(find.text('Distribua o valor entre as categorias.'), findsOneWidget);
      await digitar(tester, valorDaCategoria(1), '2000');
      expect(find.text('Distribuído R\$ 100,00 de R\$ 100,00'), findsOneWidget);
      expect(salvar(tester).onPressed, isNotNull);
      await enter(tester);

      final salvos = await lancamentosCom(tester, 'Mercado Atacadão');
      final novo = salvos.last;
      expect((novo.valorCentavos, novo.mesFatura, novo.mesReferencia, novo.faturaManual), (
        10000,
        '2026-11',
        '2026-11',
        0,
      ));
      final partes = (await tester.runAsync(() => db.lancamentosDao.carregar(novo.id)))!;
      expect(partes.categorias.map((p) => p.valorCentavos), [8000, 2000]);
    });

    testarTela('voltar ao nome escolhido não reabre a lista; Esc fecha de primeira',
        (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'atac');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mercado Atacadão'));
      await esperarBanco(tester);
      Finder sugestao() => find.descendant(
        of: find.byType(ListView),
        matching: find.text('Mercado Atacadão'),
      );
      expect(sugestao(), findsNothing);

      // Sai do nome e volta com o mouse: a lista não reaparece.
      await tester.tap(campo('Valor'));
      await tester.pumpAndSettle();
      await tester.tap(campo('Nome'));
      await tester.pumpAndSettle();
      expect(sugestao(), findsNothing);

      // Mudar o texto volta a sugerir.
      await tester.enterText(campo('Nome'), 'Mercado Ata');
      await tester.pumpAndSettle();
      expect(sugestao(), findsOneWidget);
      await tester.tap(sugestao());
      await esperarBanco(tester);
      await tester.tap(campo('Valor'));
      await tester.pumpAndSettle();
      await tester.tap(campo('Nome'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsNothing);
    });

    testarTela('Esc com a lista aberta só fecha a lista', (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'atac');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsOneWidget);
      expect(find.descendant(of: find.byType(ListView), matching: find.text('Mercado Atacadão')),
          findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(JanelaLancamento), findsNothing);
    });

    testarTela('preenche as tags e abre "Mais detalhes"', (tester) async {
      await abrir(tester);
      expect(find.text('Tags'), findsNothing);
      await teclar(tester, campo('Nome'), 'corrida');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Corrida de aplicativo'));
      await esperarBanco(tester);
      expect(texto(tester, campo('Conta ou cartão')), 'Nubank');
      expect(find.text('Transporte, Aplicativos de corrida'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'trabalho'), findsOneWidget);
    });

    testarTela('nomes de ganho só aparecem no ganho', (tester) async {
      await abrir(tester);
      await teclar(tester, campo('Nome'), 'sal');
      await tester.pumpAndSettle();
      expect(find.text('Salário'), findsNothing);

      await tester.tap(find.text('Ganho'));
      await esperarBanco(tester);
      await esperarBanco(tester);
      await tester.enterText(campo('Nome'), 'sala');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salário'));
      await esperarBanco(tester);
      expect(find.text('Salário'), findsWidgets);
      expect(texto(tester, campo('Conta')), 'Nubank');
    });
  });

  group('categorias', () {
    testarTela('a segunda categoria abre os valores e leva o foco ao primeiro', (tester) async {
      await abrir(tester);
      await digitar(tester, campo('Valor'), '10000');
      await escolherCategoria(tester, 'merc');
      expect(find.byType(CampoValor), findsOneWidget);
      await escolherCategoria(tester, 'limpe');
      expect(find.text('Casa, Mercado'), findsOneWidget);
      expect(find.text('Casa, Limpeza'), findsOneWidget);
      expect(comFoco(tester, valorDaCategoria(0)), isTrue);
      await tab(tester);
      expect(comFoco(tester, valorDaCategoria(1)), isTrue);

      // A terceira leva o foco ao valor dela.
      await escolherCategoria(tester, 'manuten');
      expect(comFoco(tester, valorDaCategoria(2)), isTrue);

      // Tirar volta a uma categoria só, sem campo de valor.
      await tester.tap(find.byTooltip('Tirar Casa, Limpeza'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tirar Casa, Manutenção'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byType(SeletorCategorias), matching: find.byType(CampoValor)),
          findsNothing);
    });

    testarTela('categoria principal e subcategoria aparecem na busca', (tester) async {
      await abrir(tester);
      await digitar(tester, campo('Categoria'), 'casa');
      await tester.pumpAndSettle();
      for (final rotulo in ['Casa', 'Casa, Aluguel', 'Casa, Mercado', 'Casa, Limpeza']) {
        expect(find.text(rotulo), findsOneWidget, reason: rotulo);
      }
      // Categorias de ganho não aparecem numa despesa.
      await tester.enterText(campo('Categoria'), 'renda');
      await tester.pumpAndSettle();
      expect(find.text('Renda extra'), findsNothing);
      await tester.enterText(campo('Categoria'), 'casa');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Casa').last);
      await tester.pumpAndSettle();
      expect(find.text('Casa'), findsOneWidget);
    });

    testarTela('categoria arquivada não aparece na busca', (tester) async {
      await abrir(
        tester,
        antes: () async {
          final todas = await db.select(db.categorias).get();
          await db.categoriasDao.arquivar(todas.firstWhere((c) => c.nome == 'Limpeza').id);
        },
      );
      await digitar(tester, campo('Categoria'), 'limpe');
      await tester.pumpAndSettle();
      expect(find.text('Casa, Limpeza'), findsNothing);
    });

    testarTela('trocar para ganho tira as categorias de despesa e o cartão', (tester) async {
      await abrir(tester);
      await escolherCategoria(tester, 'merc');
      await escolherNoMenu(tester, 'Conta ou cartão', 'Cartão Nubank');
      await tester.tap(find.text('Ganho'));
      await esperarBanco(tester);
      expect(find.text('Casa, Mercado'), findsNothing);
      expect(texto(tester, campo('Conta')), '');
      expect(find.text('Fatura'), findsNothing);
      await tester.tap(campo('Conta'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MenuItemButton, 'Cartão Nubank'), findsNothing);
      expect(find.widgetWithText(MenuItemButton, 'Inter'), findsWidgets);
    });
  });

  group('fatura', () {
    testarTela('trocada à mão não muda com a data; o mês calculado volta ao automático',
        (tester) async {
      await abrir(tester);
      await escolherNoMenu(tester, 'Conta ou cartão', 'Cartão Nubank');
      expect(texto(tester, campo('Fatura')), 'Novembro/2026');
      await tester.enterText(campo('Data'), '03/10');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(texto(tester, campo('Fatura')), 'Outubro/2026');

      await escolherNoMenu(tester, 'Fatura', 'Dezembro/2026');
      expect(find.text('Trocada à mão; não muda com a data'), findsOneWidget);
      await tester.enterText(campo('Data'), '20/10');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(texto(tester, campo('Fatura')), 'Dezembro/2026');

      await tester.enterText(campo('Nome'), 'Livro');
      await digitar(tester, campo('Valor'), '5990');
      await escolherCategoria(tester, 'livros');
      await tocar(tester, find.text('Salvar'));
      await esperarBanco(tester);
      final livro = (await lancamentosCom(tester, 'Livro')).single;
      expect((livro.mesFatura, livro.faturaManual, livro.dataLancamento), ('2026-12', 1, '2026-10-20'));
    });

    testarTela('escolher de novo o mês calculado volta ao cálculo', (tester) async {
      await abrir(tester);
      await escolherNoMenu(tester, 'Conta ou cartão', 'Cartão Nubank');
      await escolherNoMenu(tester, 'Fatura', 'Dezembro/2026');
      await escolherNoMenu(tester, 'Fatura', 'Novembro/2026');
      expect(find.text('Calculada pela data; pode trocar'), findsOneWidget);
      await tester.enterText(campo('Data'), '03/10');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(texto(tester, campo('Fatura')), 'Outubro/2026');
    });
  });

  group('mais detalhes', () {
    testarTela('tag nova, tag existente e observação', (tester) async {
      await abrir(tester);
      await tester.enterText(campo('Nome'), 'Táxi');
      await digitar(tester, campo('Valor'), '3200');
      await escolherCategoria(tester, 'corrida');
      await escolherNoMenu(tester, 'Conta ou cartão', 'Carteira');
      await tocar(tester, find.text('Mais detalhes: tags e observação'));
      await tester.pumpAndSettle();

      await digitar(tester, campo('Tags'), 'trab');
      await tester.pumpAndSettle();
      await enter(tester);
      await digitar(tester, campo('Tags'), '#aeroporto');
      await tester.pumpAndSettle();
      await enter(tester);
      expect(find.widgetWithText(InputChip, 'trabalho'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'aeroporto'), findsOneWidget);
      await tester.enterText(campo('Observação'), 'volta da viagem');
      await tester.pump();

      // Enter com o campo de tags vazio salva.
      await tocar(tester, campo('Tags'));
      await tester.pump();
      await enter(tester);
      expect(find.byType(JanelaLancamento), findsNothing);
      final taxi = (await lancamentosCom(tester, 'Táxi')).single;
      final completo = (await tester.runAsync(() => db.lancamentosDao.carregar(taxi.id)))!;
      expect(completo.tags, ['trabalho', 'aeroporto']);
      expect(taxi.observacao, 'volta da viagem');
    });
  });

  group('editar', () {
    testarTela('abre preenchida, com o título de edição, e grava no mesmo lançamento',
        (tester) async {
      await abrir(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      final mercado = (await lancamentosCom(tester, 'Mercado Atacadão')).single;
      final completo = (await tester.runAsync(() => db.lancamentosDao.carregar(mercado.id)))!;
      abrirJanelaLancamento(tester.element(find.byType(CascaPrincipal)), lancamento: completo);
      await esperarBanco(tester);

      expect(find.text('Editar lançamento'), findsOneWidget);
      expect(texto(tester, campo('Nome')), 'Mercado Atacadão');
      expect(texto(tester, campo('Valor')), 'R\$ 412,30');
      expect(texto(tester, valorDaCategoria(0)), 'R\$ 300,00');
      expect(texto(tester, valorDaCategoria(1)), 'R\$ 112,30');
      expect(texto(tester, campo('Conta ou cartão')), 'Cartão Nubank');
      expect(texto(tester, campo('Data')), '28/09/2026');
      expect(texto(tester, campo('Fatura')), 'Outubro/2026');
      expect(salvar(tester).onPressed, isNotNull);

      await tester.enterText(campo('Nome'), 'Atacadão do bairro');
      await tester.pump();
      await tocar(tester, find.text('Salvar'));
      await esperarBanco(tester);
      expect(await lancamentosCom(tester, 'Mercado Atacadão'), isEmpty);
      final editado = (await lancamentosCom(tester, 'Atacadão do bairro')).single;
      expect(editado.id, mercado.id);
      expect(editado.valorCentavos, 41230);
    });
  });
}
