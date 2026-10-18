import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:centavinhos/ui/lancamento/excluir_lancamento.dart';
import 'package:centavinhos/ui/lancamento/janela_lancamento.dart';
import 'package:centavinhos/ui/telas/mes/linha_lancamento.dart';
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

  /// Abre o app na tela do mês, com os dados de exemplo de 12/10/2026 (ou o
  /// banco vazio, sem [dadosExemplo]).
  Future<void> abrir(WidgetTester tester, {bool dadosExemplo = true}) async {
    await tester.runAsync(() async {
      if (dadosExemplo) {
        await gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12));
      } else {
        await db.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1');
      }
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
    await esperarBanco(tester);
  }

  /// Um teste de tela que sempre desmonta o app no fim, mesmo quando falha.
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

  /// Toca em [alvo], rolando a lista só se ele não estiver à vista: rolar
  /// deixaria o total do mês fora da tela.
  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    if (alvo.hitTestable().evaluate().isEmpty) await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await esperarBanco(tester);
  }

  /// Põe o foco na linha de [nome] e aperta Delete.
  Future<void> apertarDelete(WidgetTester tester, String nome) async {
    final linha = find.text(nome);
    if (linha.hitTestable().evaluate().isEmpty) await tester.ensureVisible(linha);
    Focus.of(tester.element(linha)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await esperarBanco(tester);
  }

  Future<void> desfazer(WidgetTester tester) async {
    await tester.tap(find.text('Desfazer'));
    await esperarBanco(tester);
  }

  /// Digita [teclas] no fim do campo, passando pelos formatadores.
  Future<void> teclar(WidgetTester tester, Finder alvo, String teclas) async {
    await tester.tap(alvo);
    await tester.pump();
    final editavel = find.descendant(of: alvo, matching: find.byType(EditableText));
    for (final tecla in teclas.split('')) {
      final atual = tester.widget<EditableText>(editavel).controller.text;
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '$atual$tecla',
          selection: TextSelection.collapsed(offset: atual.length + 1),
        ),
      );
      await tester.pump();
    }
  }

  Future<int> contarLancamentos(WidgetTester tester, String descricao) async =>
      (await tester.runAsync(
        () => (db.select(db.lancamentos)..where((l) => l.descricao.equals(descricao))).get(),
      ))!.length;

  group('mês e total', () {
    testarTela('abre no mês de hoje, com o total sem filtro e a lista', (tester) async {
      await abrir(tester);
      expect(find.text('Outubro 2026'), findsOneWidget);
      expect(find.text('Total do mês, sem filtro'), findsOneWidget);
      expect(find.text('R\$ 2.242,70'), findsOneWidget);
      expect(find.text('Mercado Atacadão'), findsOneWidget);
      expect(find.text('Fone Bluetooth (1/3)'), findsOneWidget);
      expect(find.text('Casa, Mercado · Nubank, vence 12/10'), findsOneWidget);
      expect(find.text('+R\$ 4.000,00'), findsOneWidget);
      expect(find.text('−R\$ 30,00'), findsOneWidget);
      expect(find.text('estorno'), findsOneWidget);
      expect(find.text('+1 categoria'), findsOneWidget);
      expect(find.text('Transferência Nubank para Inter'), findsOneWidget);
    });

    testarTela('as setas trocam o mês, e o mês fica ao voltar de outra tela', (tester) async {
      await abrir(tester);
      await tester.tap(find.byTooltip('Próximo mês'));
      await esperarBanco(tester);
      expect(find.text('Novembro 2026'), findsOneWidget);
      expect(find.text('Fone Bluetooth (2/3)'), findsOneWidget);
      expect(find.text('Fone Bluetooth (1/3)'), findsNothing);
      // Novembro: Fone (2/3), Netflix de outubro e Aluguel de novembro.
      expect(find.text('R\$ 1.344,90'), findsOneWidget);

      await tester.tap(find.text('Cadastros'));
      await esperarBanco(tester);
      await tester.tap(find.text('Mês'));
      await esperarBanco(tester);
      expect(find.text('Novembro 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Mês anterior'));
      await esperarBanco(tester);
      await tester.tap(find.byTooltip('Mês anterior'));
      await esperarBanco(tester);
      expect(find.text('Setembro 2026'), findsOneWidget);
    });

    testarTela('trocar de mês volta a lista para o topo', (tester) async {
      await abrir(tester);
      await tester.drag(find.text('Padaria'), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Total do mês, sem filtro'), findsNothing);
      await tester.tap(find.byTooltip('Próximo mês'));
      await esperarBanco(tester);
      expect(find.text('Total do mês, sem filtro'), findsOneWidget);
    });

    testarTela('mês sem lançamentos', (tester) async {
      await abrir(tester, dadosExemplo: false);
      expect(find.text('R\$ 0,00'), findsOneWidget);
      expect(
        find.text('Nenhum lançamento em outubro. Aperte + ou Ctrl+N para lançar.'),
        findsOneWidget,
      );
    });

    testarTela('"+1 categoria" abre a divisão', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('+1 categoria'));
      expect(find.text('Divisão'), findsOneWidget);
      expect(find.text('R\$ 300,00'), findsOneWidget);
      expect(find.text('R\$ 112,30'), findsOneWidget);
      // A divisão não abre a edição.
      expect(find.byType(JanelaLancamento), findsNothing);
    });

    testarTela('Esc fecha a divisão e devolve o foco à linha', (tester) async {
      await abrir(tester);
      final padaria = Focus.of(tester.element(find.text('Padaria')));
      padaria.requestFocus();
      await tester.pump();
      await tocar(tester, find.text('+1 categoria'));
      expect(find.text('Divisão'), findsOneWidget);
      expect(padaria.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Divisão'), findsNothing);
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(padaria.hasPrimaryFocus, isTrue);
    });

    testarTela('clique fora fecha a divisão sem abrir a edição', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('+1 categoria'));
      await tester.tap(find.text('Padaria'));
      await esperarBanco(tester);
      expect(find.text('Divisão'), findsNothing);
      expect(find.byType(JanelaLancamento), findsNothing);
    });
  });

  group('foco do teclado na lista', () {
    /// A borda do anel de foco na linha de [nome], ou nula sem o anel.
    BoxBorder? anel(WidgetTester tester, String nome) {
      final caixa = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.ancestor(of: find.text(nome), matching: find.byType(LinhaLancamento)),
          matching: find.byKey(const ValueKey('anel')),
        ),
      );
      return (caixa.decoration as BoxDecoration).border;
    }

    void modoDeDestaque(FocusHighlightStrategy estrategia) {
      FocusManager.instance.highlightStrategy = estrategia;
      addTearDown(
        () => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic,
      );
    }

    testarTela('com o teclado, a linha com foco ganha o anel de foco', (tester) async {
      modoDeDestaque(FocusHighlightStrategy.alwaysTraditional);
      await abrir(tester);
      expect(anel(tester, 'Padaria'), isNull);

      final padaria = Focus.of(tester.element(find.text('Padaria')));
      padaria.requestFocus();
      await tester.pumpAndSettle();
      final borda = anel(tester, 'Padaria')! as Border;
      final cores = Theme.of(tester.element(find.text('Padaria'))).colorScheme;
      expect((borda.top.color, borda.top.width), (cores.onSurface, 3.0));
      expect(anel(tester, 'Aluguel'), isNull);

      padaria.unfocus();
      await tester.pumpAndSettle();
      expect(anel(tester, 'Padaria'), isNull);
    });

    testarTela('com o mouse, o foco não acende o anel', (tester) async {
      modoDeDestaque(FocusHighlightStrategy.alwaysTouch);
      await abrir(tester);
      Focus.of(tester.element(find.text('Padaria'))).requestFocus();
      await tester.pumpAndSettle();
      expect(anel(tester, 'Padaria'), isNull);
    });
  });

  group('editar', () {
    testarTela('clique abre a edição, e o total muda ao salvar', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Padaria'));
      await esperarBanco(tester);
      expect(find.text('Editar lançamento'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);

      // R$ 18,50 vira R$ 185,00: o total sobe R$ 166,50.
      await teclar(tester, campo('Valor'), '0');
      await tester.tap(find.text('Salvar'));
      await esperarBanco(tester);
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(find.text('R\$ 185,00'), findsOneWidget);
      expect(find.text('R\$ 2.409,20'), findsOneWidget);
      expect(find.text('Lançamento "Padaria" salvo.'), findsOneWidget);
      // O lançamento continua na tela: a mensagem não tem "Ver".
      expect(find.text('Ver'), findsNothing);
    });

    testarTela('Enter na linha também abre a edição', (tester) async {
      await abrir(tester);
      Focus.of(tester.element(find.text('Padaria'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await esperarBanco(tester);
      await esperarBanco(tester);
      expect(find.text('Editar lançamento'), findsOneWidget);
    });

    testarTela('lançamento que vai para outro mês: "Ver" leva até ele', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Padaria'));
      await esperarBanco(tester);
      await tester.enterText(campo('Data'), '03/11/2026');
      await tester.pump();
      await tester.tap(find.text('Salvar'));
      await esperarBanco(tester);
      expect(find.text('Padaria'), findsNothing);

      await tester.tap(find.text('Ver'));
      await esperarBanco(tester);
      expect(find.text('Novembro 2026'), findsOneWidget);
      expect(find.text('Padaria'), findsOneWidget);
    });

    testarTela('novo lançamento feito em outra tela: "Ver" volta para o mês', (tester) async {
      await abrir(tester);
      await tester.tap(find.text('Cadastros'));
      await esperarBanco(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await esperarBanco(tester);
      await esperarBanco(tester);
      await tester.enterText(campo('Nome'), 'Sorvete');
      await teclar(tester, campo('Valor'), '900');
      await tester.enterText(
        find.descendant(of: find.byKey(const ValueKey('busca')), matching: find.byType(TextField)),
        'lanch',
      );
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(campo('Conta ou cartão'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Carteira').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await esperarBanco(tester);

      await tester.tap(find.text('Ver'));
      await esperarBanco(tester);
      expect(find.text('Outubro 2026'), findsOneWidget);
      expect(find.text('Sorvete'), findsOneWidget);
    });

    testarTela('estorno e transferência ainda não abrem a edição', (tester) async {
      await abrir(tester);
      // O estorno (02/10) vem antes da compra (15/09) na lista.
      await tocar(tester, find.text('Restaurante').first);
      expect(find.text('Editar estornos chega na etapa 5.'), findsOneWidget);
      expect(find.byType(JanelaLancamento), findsNothing);
      await tocar(tester, find.text('Transferência Nubank para Inter'));
      expect(find.text('Editar transferências chega na etapa 7.'), findsOneWidget);
      expect(find.byType(JanelaLancamento), findsNothing);
    });
  });

  group('excluir', () {
    testarTela('Delete pede confirmação, exclui e "Desfazer" devolve', (tester) async {
      await abrir(tester);
      await apertarDelete(tester, 'Padaria');
      expect(find.text('Excluir "Padaria"?'), findsOneWidget);

      // Cancelar não exclui.
      await tester.tap(find.text('Cancelar'));
      await esperarBanco(tester);
      expect(find.text('Padaria'), findsOneWidget);

      await apertarDelete(tester, 'Padaria');
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await esperarBanco(tester);
      expect(find.text('Padaria'), findsNothing);
      expect(find.text('R\$ 2.224,20'), findsOneWidget);
      expect(find.text('Lançamento "Padaria" excluído.'), findsOneWidget);

      await desfazer(tester);
      expect(find.text('Padaria'), findsOneWidget);
      expect(find.text('R\$ 2.242,70'), findsOneWidget);
    });

    testarTela('o "Desfazer" some sozinho depois de alguns segundos', (tester) async {
      await abrir(tester);
      await apertarDelete(tester, 'Padaria');
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await esperarBanco(tester);
      expect(find.text('Desfazer'), findsOneWidget);
      await tester.pump(tempoParaDesfazer);
      await tester.pumpAndSettle();
      expect(find.text('Desfazer'), findsNothing);
    });

    testarTela('parcela pela janela de edição: "Este e os próximos"', (tester) async {
      await abrir(tester);
      await tester.tap(find.byTooltip('Próximo mês'));
      await esperarBanco(tester);
      await tocar(tester, find.text('Fone Bluetooth (2/3)'));
      await esperarBanco(tester);
      await tester.tap(find.text('Excluir'));
      await esperarBanco(tester);
      expect(find.text('Excluir "Fone Bluetooth (2/3)"?'), findsOneWidget);
      expect(find.text('Esta compra foi parcelada em 3 vezes.'), findsOneWidget);

      await tester.tap(find.text('Este e os próximos'));
      await esperarBanco(tester);
      // A janela de edição fecha junto.
      expect(find.byType(JanelaLancamento), findsNothing);
      expect(find.text('Fone Bluetooth (2/3)'), findsNothing);
      expect(find.text('2 lançamentos "Fone Bluetooth" excluídos.'), findsOneWidget);
      expect(await contarLancamentos(tester, 'Fone Bluetooth'), 1);

      await desfazer(tester);
      expect(find.text('Fone Bluetooth (2/3)'), findsOneWidget);
      expect(await contarLancamentos(tester, 'Fone Bluetooth'), 3);
    });

    testarTela('recorrente: as três opções falam em meses', (tester) async {
      await abrir(tester);
      await apertarDelete(tester, 'Aluguel');
      expect(find.textContaining('se repete todo mês'), findsOneWidget);
      expect(find.text('Só este'), findsOneWidget);
      expect(find.text('1 mês'), findsOneWidget);
      expect(find.text('2 meses'), findsOneWidget);
      expect(find.text('3 meses'), findsOneWidget);
      await tester.tap(find.text('Todos'));
      await esperarBanco(tester);
      expect(await contarLancamentos(tester, 'Aluguel'), 0);
    });

    testarTela('transferência pelo Delete', (tester) async {
      await abrir(tester);
      await apertarDelete(tester, 'Transferência Nubank para Inter');
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await esperarBanco(tester);
      expect(find.text('Transferência Nubank para Inter'), findsNothing);
      expect(find.text('Transferência excluída.'), findsOneWidget);
      // Transferência não conta nos gastos: o total não muda.
      expect(find.text('R\$ 2.242,70'), findsOneWidget);
    });
  });
}
