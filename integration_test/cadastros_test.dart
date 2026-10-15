import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'app_de_teste.dart';

void main() {
  prepararTestesDeIntegracao();

  testWidgets('conta com saldo de outra data, categoria nova, excluir e arquivar', (
    tester,
  ) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Cadastros').last);

    // 1. Nova conta: Reserva, no cheque especial, com o saldo do dia 1º.
    await tocar(tester, find.text('Nova conta'));
    expect(textoDoCampo(tester, campo('Saldo em')), '12/10/2026');
    await tester.enterText(campo('Nome da conta'), 'Reserva');
    final saldo = campo('Saldo inicial');
    await digitar(tester, saldo, ['5', '0', '0', '0', '0', '-']);
    expect(textoDoCampo(tester, saldo), '−R\$ 500,00');
    await tester.enterText(campo('Saldo em'), '1/10');
    await tester.pump();
    await tocar(tester, find.text('Salvar'));
    expect(find.text('Reserva'), findsOneWidget);
    expect(find.text('Banco · saldo inicial em 01/10/2026'), findsWidgets);
    expect(find.text('−R\$ 500,00'), findsOneWidget);

    final reserva = (await banco.contasDao.observar().first)
        .singleWhere((c) => c.conta.nome == 'Reserva')
        .conta;
    expect((reserva.tipo, reserva.saldoInicialCentavos, reserva.dataSaldoInicial), (
      'banco',
      -50000,
      '2026-10-01',
    ));

    // 2. Categoria Pets com a subcategoria Ração.
    await tocar(tester, find.text('Categorias'));
    await tocar(tester, find.text('Nova categoria'));
    await tester.enterText(campo('Nome da categoria'), 'Pets');
    await tester.pump();
    await tocar(tester, find.text('Salvar'));
    await tocar(tester, acaoDaLinha('Pets', 'Nova subcategoria'));
    await tester.enterText(campo('Nome da subcategoria'), 'Ração');
    await tester.pump();
    await tocar(tester, find.text('Salvar'));
    expect(find.text('Ração'), findsOneWidget);
    expect(find.text('1 subcategoria'), findsOneWidget);

    // 3. Pets nunca foi usada: excluir apaga ela e a Ração.
    await tocar(tester, acaoDaLinha('Pets', 'Excluir'));
    expect(find.textContaining('A subcategoria dela também.'), findsOneWidget);
    await tocar(tester, find.widgetWithText(FilledButton, 'Excluir'));
    expect(find.text('Pets'), findsNothing);
    expect(find.text('Ração'), findsNothing);

    // 4. Casa foi usada: só arquiva, com as subcategorias, e volta em
    // "Mostrar arquivadas".
    await tocar(tester, acaoDaLinha('Casa', 'Arquivar'));
    expect(find.textContaining('já foi usada, então não pode ser apagada'), findsOneWidget);
    await tocar(tester, find.widgetWithText(FilledButton, 'Arquivar'));
    expect(find.text('Casa'), findsNothing);
    expect(find.text('Mercado'), findsNothing);

    await tocar(tester, find.text('Mostrar arquivadas'));
    await rolarAte(tester, find.text('Casa'));
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('5 subcategorias · arquivada'), findsOneWidget);
    final categorias = await banco.categoriasDao.observar().first;
    final casa = categorias.singleWhere((c) => c.categoria.nome == 'Casa').categoria;
    expect(
      categorias
          .where((c) => c.categoria.id == casa.id || c.categoria.categoriaPaiId == casa.id)
          .every((c) => c.categoria.arquivada == 1),
      isTrue,
    );

    // 5. Desarquivar traz a Casa e as subcategorias de volta.
    await tocar(tester, acaoDaLinha('Casa', 'Desarquivar'));
    expect(find.text('5 subcategorias'), findsOneWidget);
  });
}
