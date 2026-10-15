import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:centavinhos/ui/widgets/lista_cadastro.dart';
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

  Future<void> fechar(WidgetTester tester) async {
    // Desmonta antes de fechar o banco, para encerrar os fluxos do Drift.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// Abre o app com os dados de exemplo de 12/10/2026 e vai até [destino].
  Future<void> abrir(WidgetTester tester, String destino) async {
    await tester.runAsync(() => gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12)));
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
    await tester.tap(find.text(destino).last);
    await esperarBanco(tester);
  }

  /// Um teste de tela que sempre desmonta o app no fim, mesmo quando falha.
  /// Sem isso, fechar o banco esperaria pelos fluxos da tela e travaria.
  void testarTela(String descricao, Future<void> Function(WidgetTester tester) corpo) {
    testWidgets(descricao, (tester) async {
      try {
        await corpo(tester);
      } finally {
        await fechar(tester);
      }
    });
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.tap(alvo);
    await esperarBanco(tester);
  }

  Finder campo(String rotulo) => find.widgetWithText(TextField, rotulo);

  /// Botão de ação (pela dica) na linha do item [nome].
  Finder acaoDaLinha(String nome, String dica) => find.descendant(
    of: find.ancestor(of: find.text(nome), matching: find.byType(LinhaCadastro)),
    matching: find.byTooltip(dica),
  );

  FilledButton salvar(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'));

  group('contas', () {
    testarTela('lista com tipo, data e saldo inicial; usada arquiva', (tester) async {
      await abrir(tester, 'Cadastros');
      expect(find.text('Nubank'), findsOneWidget);
      expect(find.text('R\$ 1.640,00'), findsOneWidget);
      expect(find.textContaining('Banco · saldo inicial em 01/09/2026'), findsWidgets);
      // As três contas dos exemplos já foram usadas.
      expect(find.byTooltip('Arquivar'), findsNWidgets(3));
      expect(find.byTooltip('Excluir'), findsNothing);
    });

    testarTela('nova conta: travas do Salvar e conta salva com data passada', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Nova conta'));
      expect(find.text('Nova conta'), findsWidgets);
      expect(textoDoCampo(tester, campo('Saldo em')), '12/10/2026');
      expect(find.text('Dê um nome à conta.'), findsOneWidget);
      expect(salvar(tester).onPressed, isNull);

      await tester.enterText(campo('Nome da conta'), 'nubank');
      await tester.pump();
      expect(find.text('Já existe uma conta com esse nome.'), findsOneWidget);

      await tester.enterText(campo('Nome da conta'), 'Reserva');
      await tester.enterText(campo('Saldo em'), '13/10');
      await tester.pump();
      expect(find.text('A data do saldo não pode ser depois de hoje.'), findsOneWidget);
      await tester.enterText(campo('Saldo em'), '31/02');
      await tester.pump();
      expect(find.text('Data inválida. Use dd/mm ou dd/mm/aaaa.'), findsOneWidget);

      await tester.enterText(campo('Saldo em'), '1/10');
      await tester.pump();
      expect(salvar(tester).onPressed, isNotNull);
      await tocar(tester, find.text('Salvar'));

      expect(find.text('Reserva'), findsOneWidget);
      expect(find.textContaining('saldo inicial em 01/10/2026'), findsOneWidget);
      // Nunca usada: dá para excluir.
      expect(acaoDaLinha('Reserva', 'Excluir'), findsOneWidget);
    });

    testarTela('Enter no nome salva e Esc cancela', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Nova conta'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await esperarBanco(tester);
      expect(find.byType(AlertDialog), findsNothing);

      await tocar(tester, find.text('Nova conta'));
      await tester.enterText(campo('Nome da conta'), 'Poupança');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await esperarBanco(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Poupança'), findsOneWidget);
    });

    testarTela('campo de data reescreve dd/mm como dd/mm/aaaa ao sair', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Nova conta'));
      await tester.enterText(campo('Saldo em'), '5/9');
      await tester.tap(campo('Nome da conta'));
      await tester.pump();
      expect(textoDoCampo(tester, campo('Saldo em')), '05/09/2026');

      await tocar(tester, find.byTooltip('Abrir calendário'));
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testarTela('conta que paga cartão ativo não é arquivada', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, acaoDaLinha('Nubank', 'Arquivar'));
      expect(find.text('Não é possível arquivar "Nubank"'), findsOneWidget);
      expect(find.text('Troque antes a conta que paga o cartão Nubank.'), findsOneWidget);
      await tocar(tester, find.text('Entendi'));
      expect(find.text('Nubank'), findsOneWidget);
    });
  });

  group('categorias', () {
    testarTela('despesas e ganhos, com as subcategorias', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Categorias'));
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('3 subcategorias'), findsWidgets);
      expect(find.text('Restaurantes'), findsOneWidget);

      await tocar(tester, find.text('Ganhos'));
      expect(find.text('Alimentação'), findsNothing);
      expect(find.text('Salário'), findsOneWidget);
      expect(find.text('sem subcategorias'), findsWidgets);
    });

    testarTela('nova subcategoria não repete o nome de uma irmã', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Categorias'));
      await tocar(tester, acaoDaLinha('Alimentação', 'Nova subcategoria'));
      expect(find.text('Nova subcategoria de Alimentação'), findsOneWidget);

      await tester.enterText(campo('Nome da subcategoria'), 'lanches');
      await tester.pump();
      expect(find.text('Já existe uma subcategoria com esse nome.'), findsOneWidget);

      await tester.enterText(campo('Nome da subcategoria'), 'Padaria');
      await tester.pump();
      await tocar(tester, find.text('Salvar'));
      expect(find.text('Padaria'), findsOneWidget);
      expect(find.text('4 subcategorias'), findsOneWidget);
    });

    testarTela('excluir categoria nunca usada leva as subcategorias', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Categorias'));
      await tester.scrollUntilVisible(
        find.text('Educação'),
        200,
        scrollable: find
            .ancestor(of: find.text('Alimentação'), matching: find.byType(Scrollable))
            .first,
      );
      await tester.pumpAndSettle();
      await tocar(tester, acaoDaLinha('Educação', 'Excluir'));
      expect(find.text('Excluir "Educação"?'), findsOneWidget);
      expect(
        find.text(
          'Esta categoria nunca foi usada e será apagada de vez. '
          'As 2 subcategorias dela também.',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
      expect(find.text('Educação'), findsNothing);
      expect(find.text('Cursos'), findsNothing);
      expect(find.text('Categoria "Educação" excluída.'), findsOneWidget);
    });
  });

  group('tags', () {
    testarTela('arquivar some da lista; "Mostrar arquivadas" traz de volta', (tester) async {
      await abrir(tester, 'Cadastros');
      await tocar(tester, find.text('Tags'));
      expect(find.text('usada em 2 lançamentos'), findsOneWidget);
      expect(acaoDaLinha('viagem', 'Excluir'), findsOneWidget);

      await tocar(tester, acaoDaLinha('trabalho', 'Arquivar'));
      expect(find.text('Arquivar "trabalho"?'), findsOneWidget);
      await tocar(tester, find.widgetWithText(FilledButton, 'Arquivar'));
      expect(find.text('trabalho'), findsNothing);

      await tocar(tester, find.text('Mostrar arquivadas'));
      expect(find.text('trabalho'), findsOneWidget);
      expect(find.text('usada em 2 lançamentos · arquivada'), findsOneWidget);
      await tocar(tester, acaoDaLinha('trabalho', 'Desarquivar'));
      expect(find.text('usada em 2 lançamentos'), findsOneWidget);
    });
  });

  group('cartões', () {
    testarTela('lista e detalhe do cartão escolhido', (tester) async {
      await abrir(tester, 'Cartões');
      expect(find.text('Fecha dia 8 · vence dia 15'), findsOneWidget);
      expect(find.text('Dia 8'), findsOneWidget);

      await tocar(tester, find.text('Fecha dia 5 · vence dia 12'));
      expect(find.text('Dia 5'), findsOneWidget);
      expect(find.text('Dia 12'), findsOneWidget);
      expect(find.text('Arquivar'), findsOneWidget);
    });

    testarTela('novo cartão: travas do Salvar e cartão escolhido depois', (tester) async {
      await abrir(tester, 'Cartões');
      await tocar(tester, find.text('Novo cartão'));
      expect(find.text('Dê um nome ao cartão.'), findsOneWidget);

      await tester.enterText(campo('Nome do cartão'), 'C6');
      await tester.enterText(campo('Fechamento'), '32');
      await tester.enterText(campo('Vencimento'), '10');
      await tester.pump();
      expect(find.text('Fechamento e vencimento vão de 1 a 31.'), findsOneWidget);

      await tester.enterText(campo('Fechamento'), '1');
      await tester.pump();
      expect(find.text('Escolha a conta que paga o cartão.'), findsOneWidget);
      expect(salvar(tester).onPressed, isNull);

      await tocar(tester, find.byType(DropdownMenu<int>));
      await tocar(tester, find.widgetWithText(MenuItemButton, 'Carteira').last);
      await tocar(tester, find.text('Salvar'));

      expect(find.text('C6'), findsWidgets);
      expect(find.text('Dia 1'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });
  });
}

/// Texto que está dentro de um campo.
String textoDoCampo(WidgetTester tester, Finder alvo) => tester
    .widget<EditableText>(find.descendant(of: alvo, matching: find.byType(EditableText)))
    .controller
    .text;
