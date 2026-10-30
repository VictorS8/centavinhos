import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/ui/lancamento/janela_lancamento.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, OrderingTerm;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_de_teste.dart';

void main() {
  prepararTestesDeIntegracao();

  /// Campo de texto que tem o foco do teclado agora.
  bool comFoco(WidgetTester tester, Finder alvo) => tester
      .widget<EditableText>(find.descendant(of: alvo, matching: find.byType(EditableText)))
      .focusNode
      .hasFocus;

  Future<void> tab(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }

  /// Enter no campo de texto com foco.
  Future<void> enter(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  /// Digita no campo que já tem o foco, tecla por tecla.
  Future<void> teclar(WidgetTester tester, Finder alvo, String teclas) async {
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
    await tester.pumpAndSettle();
  }

  testWidgets('compra parcelada só pelo teclado, com as parcelas nos meses certos', (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();

    // 1. Ctrl+N, nome, Tab, valor, Tab até a recorrência: digitar marca
    // "Parcelada" e o Enter escolhe.
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);
    await teclar(tester, campo('Nome'), 'Fone');
    await tab(tester);
    await teclar(tester, campo('Valor'), '30000');
    await tab(tester);
    expect(comFoco(tester, campo('Recorrência')), isTrue);
    // O campo já mostra "Única"; digitar troca o texto todo.
    tester.testTextInput.enterText('parc');
    await tester.pumpAndSettle();
    await enter(tester);
    expect(textoDoCampo(tester, campo('Recorrência')), 'Parcelada');

    // 2. Tab até as parcelas, que mostram a divisão.
    await tab(tester);
    expect(comFoco(tester, campo('Parcelas')), isTrue);
    await teclar(tester, campo('Parcelas'), '3');
    expect(find.text('3x de R\$ 100,00'), findsOneWidget);

    // 3. Categoria, cartão (o menu só tem cartões), a chave Estorno e a
    // data; o Enter na data salva.
    await tab(tester);
    expect(comFoco(tester, campo('Categoria')), isTrue);
    await teclar(tester, campo('Categoria'), 'eletr');
    await enter(tester);
    await tab(tester);
    expect(comFoco(tester, campo('Cartão')), isTrue);
    await teclar(tester, campo('Cartão'), 'nub');
    await enter(tester);
    expect(textoDoCampo(tester, campo('Cartão')), 'Cartão Nubank');
    expect(textoDoCampo(tester, campo('Fatura')), 'Novembro/2026');
    await tab(tester);
    expect(find.byType(Switch), findsOneWidget);
    await tab(tester);
    expect(comFoco(tester, campo('Data')), isTrue);
    await enter(tester);
    expect(find.byType(JanelaLancamento), findsNothing);
    expect(find.text('Lançamento "Fone" salvo em 3 parcelas.'), findsOneWidget);

    final parcelas = await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Fone'))
          ..orderBy([(l) => OrderingTerm(expression: l.parcelaAtual)]))
        .get();
    expect(parcelas.map((l) => (l.valorCentavos, l.mesFatura)), [
      (10000, '2026-11'),
      (10000, '2026-12'),
      (10000, '2027-01'),
    ]);

    // 4. "Ver" leva a novembro, com a 1ª parcela; as outras vêm nos meses
    // seguintes.
    await tocar(tester, find.text('Ver'));
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Fone (1/3)'), findsOneWidget);
    await tocar(tester, find.byTooltip('Próximo mês'));
    expect(find.text('Fone (2/3)'), findsOneWidget);
    await tocar(tester, find.byTooltip('Próximo mês'));
    expect(find.text('Janeiro 2027'), findsOneWidget);
    expect(find.text('Fone (3/3)'), findsOneWidget);
  });

  testWidgets('estorno vira crédito na fatura, e o fechamento novo move os lançamentos',
      (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();

    // 1. Estorno de R$ 150,00 do fone: o nome conhecido preenche o cartão
    // e a categoria; a chave volta a recorrência para Única.
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);
    await teclar(tester, campo('Nome'), 'fone blue');
    await enter(tester);
    expect(textoDoCampo(tester, campo('Recorrência')), 'Parcelada');
    await tocar(tester, find.byType(Switch));
    expect(textoDoCampo(tester, campo('Recorrência')), 'Única');
    await digitar(tester, campo('Valor'), '15000'.split(''));
    await tocar(tester, find.text('Salvar'));
    expect(find.byType(JanelaLancamento), findsNothing);
    final estorno = await (banco.select(banco.lancamentos)
          ..where((l) => l.tipo.equals('estorno') & l.descricao.equals('Fone Bluetooth')))
        .getSingle();
    expect((estorno.valorCentavos, estorno.mesFatura), (15000, '2026-11'));

    // 2. Em Cartões, novembro (R$ 100,00 − R$ 150,00) fica em zero e o
    // crédito abate dezembro.
    await tocar(tester, find.text('Cartões').last);
    await tocar(tester, find.text('Fecha dia 5 · vence dia 12'));
    expect(find.text('Crédito de R\$ 50,00 para a próxima fatura'), findsOneWidget);
    expect(find.text('Inclui crédito de R\$ 50,00 da anterior'), findsOneWidget);
    expect(find.text('R\$ 0,00'), findsOneWidget);
    expect(find.text('R\$ 50,00'), findsOneWidget);

    // 3. Fechando dia 20, o Combustível (18/09), o Restaurante (15/09) e o
    // estorno (12/10) mudam de fatura.
    await tocar(tester, find.text('Editar cartão'));
    await tester.enterText(campo('Fechamento'), '20');
    await tester.enterText(campo('Vencimento'), '27');
    await tester.pump();
    await tocar(tester, find.text('Salvar'));
    expect(find.text('3 lançamentos mudaram de fatura.'), findsOneWidget);
    expect(find.text('Setembro 2026'), findsOneWidget);
    final depois = await (banco.select(banco.lancamentos)
          ..where((l) => l.id.equals(estorno.id)))
        .getSingle();
    expect((depois.mesFatura, depois.mesReferencia), ('2026-10', '2026-10'));
  });
}
