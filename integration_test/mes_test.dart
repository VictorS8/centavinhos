import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/ui/lancamento/janela_lancamento.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_de_teste.dart';

void main() {
  prepararTestesDeIntegracao();

  /// Põe o foco do teclado na linha do lançamento [nome].
  Future<void> focarLinha(WidgetTester tester, String nome) async {
    Focus.of(tester.element(find.text(nome))).requestFocus();
    await tester.pumpAndSettle();
  }

  testWidgets('navegar entre meses e editar um lançamento pelo teclado', (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();

    // 1. Abre em outubro, com o total sem filtro (despesas − estorno).
    expect(find.text('Outubro 2026'), findsOneWidget);
    expect(find.text('R\$ 2.242,70'), findsOneWidget);
    expect(find.text('Casa, Mercado · Nubank, vence 12/10'), findsOneWidget);

    // 2. As setas trocam o mês: novembro tem a parcela 2 do fone.
    await tocar(tester, find.byTooltip('Próximo mês'));
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Fone Bluetooth (2/3)'), findsOneWidget);
    expect(find.text('R\$ 1.344,90'), findsOneWidget);
    await tocar(tester, find.byTooltip('Mês anterior'));
    expect(find.text('Outubro 2026'), findsOneWidget);

    // 3. Enter na linha abre a edição, já preenchida.
    await focarLinha(tester, 'Padaria');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Editar lançamento'), findsOneWidget);
    expect(textoDoCampo(tester, campo('Valor')), 'R\$ 18,50');

    // 4. Mais um zero no valor (R$ 185,00) e Enter salva: o total sobe.
    await digitar(tester, campo('Valor'), ['0']);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(JanelaLancamento), findsNothing);
    expect(find.text('Lançamento "Padaria" salvo.'), findsOneWidget);
    expect(find.text('R\$ 185,00'), findsOneWidget);
    expect(find.text('R\$ 2.409,20'), findsOneWidget);
    final padaria = await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Padaria')))
        .getSingle();
    expect(padaria.valorCentavos, 18500);
  });

  testWidgets('excluir as próximas parcelas e desfazer', (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();
    Future<int> parcelas() async => (await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Fone Bluetooth')))
        .get()).length;

    // 1. Em novembro, o clique na parcela 2 abre a edição; "Excluir" pergunta
    // o que excluir.
    await tocar(tester, find.byTooltip('Próximo mês'));
    await tocar(tester, find.text('Fone Bluetooth (2/3)'));
    expect(find.text('Editar lançamento'), findsOneWidget);
    await tocar(tester, find.text('Excluir'));
    expect(find.text('Excluir "Fone Bluetooth (2/3)"?'), findsOneWidget);
    expect(find.text('Só este'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);

    // 2. "Este e os próximos" tira a 2 e a 3, e a janela fecha junto.
    await tocar(tester, find.text('Este e os próximos'));
    expect(find.byType(JanelaLancamento), findsNothing);
    expect(find.text('Fone Bluetooth (2/3)'), findsNothing);
    expect(find.text('2 lançamentos "Fone Bluetooth" excluídos.'), findsOneWidget);
    expect(await parcelas(), 1);

    // 3. "Desfazer" devolve as duas.
    await tocar(tester, find.text('Desfazer'));
    expect(find.text('Fone Bluetooth (2/3)'), findsOneWidget);
    expect(await parcelas(), 3);

    // 4. Delete numa linha comum: confirma com Enter e o total cai.
    await tocar(tester, find.byTooltip('Mês anterior'));
    await focarLinha(tester, 'Padaria');
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(find.text('Excluir "Padaria"?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Padaria'), findsNothing);
    expect(find.text('R\$ 2.224,20'), findsOneWidget);
  });
}
