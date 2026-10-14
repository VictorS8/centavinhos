import 'package:centavinhos/data/configuracoes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_de_teste.dart';

void main() {
  prepararTestesDeIntegracao();

  testWidgets('primeira abertura completa: conta negativa, cartão e Ctrl+N', (tester) async {
    final banco = await abrirApp(tester);

    // 1. Banco vazio abre nas boas-vindas, já com a Carteira.
    expect(find.text('Boas-vindas ao Centavinhos'), findsOneWidget);
    expect(textoDoCampo(tester, campo('Nome da conta')), 'Carteira');

    // 2. Segunda conta: Nubank, banco.
    await tester.tap(find.text('Adicionar conta'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('Nome da conta', posicao: 1), 'Nubank');
    await tester.pump();
    await tester.tap(find.text('Banco').at(1));
    await tester.pump();

    // 3. Saldo do Nubank no cheque especial: 2, 0, 0, 0, 0 e "-".
    final saldoNubank = campo('Saldo hoje', posicao: 1);
    await digitar(tester, saldoNubank, ['2', '0', '0', '0', '0', '-']);
    expect(textoDoCampo(tester, saldoNubank), '−R\$ 200,00');

    // 4. Cartão Nubank: fecha dia 5, vence dia 12, pago pela conta Nubank.
    await tester.tap(find.text('Adicionar cartão'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('Nome do cartão'), 'Nubank');
    await tester.enterText(campo('Fechamento'), '5');
    await tester.enterText(campo('Vencimento'), '12');
    await tester.pump();
    expect(find.text('Escolha a conta que paga cada cartão.'), findsOneWidget);
    await tester.tap(find.byType(DropdownMenu<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Nubank').last);
    await tester.pumpAndSettle();

    // 5. Nada trava o botão. Só com o teclado: Tab até "Começar", que ganha
    // o anel de foco, e Enter leva para a tela do mês.
    expect(find.text('Escolha a conta que paga cada cartão.'), findsNothing);
    final foco = Focus.of(tester.element(find.text('Começar')));
    for (var i = 0; i < 40 && !foco.hasPrimaryFocus; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(foco.hasPrimaryFocus, isTrue);
    final comecar = find.widgetWithText(FilledButton, 'Começar');
    final borda = tester
        .widget<Material>(find.descendant(of: comecar, matching: find.byType(Material)).first)
        .shape! as OutlinedBorder;
    expect(borda.side.color, Theme.of(tester.element(comecar)).colorScheme.onSurface);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Outubro 2026'), findsOneWidget);

    // 6. O banco guardou o que foi digitado.
    final contas = await banco.select(banco.contas).get();
    expect(
      contas.map((c) => (c.nome, c.tipo, c.saldoInicialCentavos, c.dataSaldoInicial)),
      [('Carteira', 'carteira', 0, '2026-10-12'), ('Nubank', 'banco', -20000, '2026-10-12')],
    );
    final cartao = await banco.select(banco.cartoes).getSingle();
    expect((cartao.nome, cartao.diaFechamento, cartao.diaVencimento), ('Nubank', 5, 12));
    expect(cartao.contaPagamentoId, contas[1].id);
    final configuracoes = await banco.observarConfiguracoes().first;
    expect(configuracoes[ChaveConfiguracao.boasVindasConcluida], '1');

    // 7. Ctrl+N abre o aviso de novo lançamento e Esc fecha.
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);
    expect(find.text('O lançamento rápido chega na etapa 3.'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('O lançamento rápido chega na etapa 3.'), findsNothing);
  });

  testWidgets('barra lateral troca de tela e mantém o botão +', (tester) async {
    final banco = await abrirApp(tester);
    await banco.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1');
    await tester.pumpAndSettle();

    for (final (destino, texto) in [
      ('Filtros', 'Esta tela chega na etapa 8.'),
      ('Cartões', 'Esta tela chega na etapa 2.'),
      ('Ajustes', 'Esta tela chega na etapa 10.'),
      ('Mês', 'Esta tela chega na etapa 4.'),
    ]) {
      await tester.tap(find.text(destino).last);
      await tester.pumpAndSettle();
      expect(find.text(texto), findsOneWidget, reason: destino);
    }

    await tester.tap(find.byTooltip('Novo lançamento (Ctrl+N)'));
    await tester.pumpAndSettle();
    expect(find.text('Novo lançamento'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
  });
}
