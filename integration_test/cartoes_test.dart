import 'package:centavinhos/data/database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_de_teste.dart';

void main() {
  prepararTestesDeIntegracao();

  testWidgets('novo cartão, editar o vencimento e conta que paga não arquiva', (tester) async {
    final banco = await abrirApp(tester);
    await banco.concluirBoasVindas(
      contas: const [
        NovaConta(nome: 'Carteira', tipo: 'carteira', saldoInicialCentavos: 40000),
        NovaConta(nome: 'Nubank', tipo: 'banco', saldoInicialCentavos: 0),
      ],
      hoje: hojeDosTestes,
    );
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Cartões').last);
    expect(find.text('Nenhum cartão cadastrado'), findsOneWidget);

    // 1. Novo cartão, todo pelo teclado: nome, Tab, fechamento, Tab,
    // vencimento e a conta no menu.
    await tocar(tester, find.text('Novo cartão'));
    await tester.enterText(campo('Nome do cartão'), 'Nubank');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.enterText(campo('Fechamento'), '5');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.enterText(campo('Vencimento'), '12');
    await tester.pump();
    expect(find.text('Escolha a conta que paga o cartão.'), findsOneWidget);
    await tocar(tester, find.byType(DropdownMenu<int>));
    await tocar(tester, find.widgetWithText(MenuItemButton, 'Nubank').last);
    expect(find.text('Escolha a conta que paga o cartão.'), findsNothing);
    await tocar(tester, find.text('Salvar'));

    expect(find.text('Fecha dia 5 · vence dia 12'), findsOneWidget);
    expect(find.text('Dia 5'), findsOneWidget);
    expect(find.text('Dia 12'), findsOneWidget);
    // Nunca usado: o botão é de excluir.
    expect(find.text('Excluir'), findsOneWidget);

    // 2. Editar: o vencimento passa para o dia 20; Enter no campo salva.
    await tocar(tester, find.text('Editar cartão'));
    expect(textoDoCampo(tester, campo('Vencimento')), '12');
    await tester.enterText(campo('Vencimento'), '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Fecha dia 5 · vence dia 20'), findsOneWidget);

    final cartao = (await banco.cartoesDao.observar().first).single.cartao;
    final contas = await banco.contasDao.observar().first;
    final nubank = contas.singleWhere((c) => c.conta.nome == 'Nubank').conta;
    expect((cartao.nome, cartao.diaFechamento, cartao.diaVencimento), ('Nubank', 5, 20));
    expect(cartao.contaPagamentoId, nubank.id);

    // 3. A conta que paga o cartão não pode ser arquivada nem excluída.
    await tocar(tester, find.text('Cadastros').last);
    expect(acaoDaLinha('Nubank', 'Arquivar'), findsOneWidget);
    await tocar(tester, acaoDaLinha('Nubank', 'Arquivar'));
    expect(find.text('Troque antes a conta que paga o cartão Nubank.'), findsOneWidget);
    await tocar(tester, find.text('Entendi'));

    // 4. Excluído o cartão (nunca usado), a conta deixa de estar em uso e
    // pode ser excluída.
    await tocar(tester, find.text('Cartões').last);
    await tocar(tester, find.widgetWithText(OutlinedButton, 'Excluir'));
    expect(find.text('Excluir "Nubank"?'), findsOneWidget);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
    expect(find.text('Nenhum cartão cadastrado'), findsOneWidget);
    await tocar(tester, find.text('Cadastros').last);
    await tocar(tester, acaoDaLinha('Nubank', 'Excluir'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
    expect(find.text('Nubank'), findsNothing);
  });
}
