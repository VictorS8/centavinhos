import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/ui/lancamento/janela_lancamento.dart';
import 'package:centavinhos/ui/lancamento/seletor_categorias.dart';
import 'package:centavinhos/ui/widgets/campo_valor.dart';
import 'package:drift/drift.dart' show OrderingTerm;
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

  testWidgets('lançamento só pelo teclado: Ctrl+N, Tab e Enter', (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();

    // 1. Ctrl+N abre a janela com o foco no nome.
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);
    expect(find.text('Novo lançamento'), findsOneWidget);
    expect(comFoco(tester, campo('Nome')), isTrue);

    // 2. Nome, Tab, valor estilo caixa eletrônico, Tab, Tab (recorrência).
    await teclar(tester, campo('Nome'), 'Pão de queijo');
    await tab(tester);
    expect(comFoco(tester, campo('Valor')), isTrue);
    await teclar(tester, campo('Valor'), '1250');
    expect(textoDoCampo(tester, campo('Valor')), 'R\$ 12,50');
    await tab(tester);
    expect(comFoco(tester, campo('Recorrência')), isTrue);
    await tab(tester);

    // 3. Categoria pela busca, escolhida com Enter.
    expect(comFoco(tester, campo('Categoria')), isTrue);
    await teclar(tester, campo('Categoria'), 'lanch');
    await enter(tester);
    expect(find.text('Alimentação, Lanches'), findsOneWidget);

    // 4. Tab até a conta; digitar marca a opção e o Enter escolhe.
    await tab(tester);
    expect(comFoco(tester, campo('Conta ou cartão')), isTrue);
    await teclar(tester, campo('Conta ou cartão'), 'cart');
    await enter(tester);
    expect(textoDoCampo(tester, campo('Conta ou cartão')), 'Carteira');

    // 5. Tab até a data (hoje) e Enter salva.
    await tab(tester);
    expect(comFoco(tester, campo('Data')), isTrue);
    expect(textoDoCampo(tester, campo('Data')), '12/10/2026');
    await enter(tester);
    expect(find.byType(JanelaLancamento), findsNothing);
    expect(find.text('Lançamento "Pão de queijo" salvo.'), findsOneWidget);

    final salvo = await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Pão de queijo')))
        .getSingle();
    expect(
      (salvo.tipo, salvo.valorCentavos, salvo.dataLancamento, salvo.mesReferencia, salvo.cartaoId),
      ('despesa', 1250, '2026-10-12', '2026-10', null),
    );

    // 6. Esc cancela sem gravar nada.
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);
    await teclar(tester, campo('Nome'), 'Não vai');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(JanelaLancamento), findsNothing);
    final naoVai = await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Não vai')))
        .get();
    expect(naoVai, isEmpty);
  });

  testWidgets('nome conhecido, duas categorias no cartão e tag nova', (tester) async {
    final banco = await abrirApp(tester);
    await gerarDadosExemplo(banco, hoje: hojeDosTestes);
    await tester.pumpAndSettle();
    await apertarCtrl(tester, LogicalKeyboardKey.keyN);

    // 1. O nome conhecido preenche categorias, cartão e fatura; o valor não.
    await teclar(tester, campo('Nome'), 'atac');
    expect(find.text('Mercado Atacadão'), findsOneWidget);
    await enter(tester);
    expect(find.text('Casa, Mercado'), findsOneWidget);
    expect(find.text('Casa, Limpeza'), findsOneWidget);
    expect(textoDoCampo(tester, campo('Conta ou cartão')), 'Cartão Nubank');
    expect(textoDoCampo(tester, campo('Fatura')), 'Novembro/2026');
    expect(textoDoCampo(tester, campo('Valor')), 'R\$ 0,00');

    // 2. Valor e distribuição: o Salvar só libera quando a soma bate.
    final valores = find.descendant(
      of: find.byType(SeletorCategorias),
      matching: find.byType(CampoValor),
    );
    await tab(tester);
    await teclar(tester, campo('Valor'), '10000');
    await tocar(tester, valores.at(0));
    await teclar(tester, valores.at(0), '8000');
    expect(find.text('Distribuído R\$ 80,00 de R\$ 100,00, faltam R\$ 20,00'), findsOneWidget);
    final salvar = find.widgetWithText(FilledButton, 'Salvar');
    expect(tester.widget<FilledButton>(salvar).onPressed, isNull);
    await tab(tester);
    await teclar(tester, valores.at(1), '2000');
    expect(find.text('Distribuído R\$ 100,00 de R\$ 100,00'), findsOneWidget);

    // 3. Compra em 03/10, antes do fechamento (dia 5): fatura de outubro.
    await tester.enterText(campo('Data'), '03/10');
    await tester.pumpAndSettle();
    expect(textoDoCampo(tester, campo('Fatura')), 'Outubro/2026');

    // 4. Tag nova em "Mais detalhes".
    await tocar(tester, find.text('Mais detalhes: tags e observação'));
    await tocar(tester, campo('Tags'));
    await teclar(tester, campo('Tags'), 'atacado');
    await enter(tester);
    expect(find.widgetWithText(InputChip, 'atacado'), findsOneWidget);

    await tocar(tester, salvar);
    expect(find.byType(JanelaLancamento), findsNothing);

    final novo = await (banco.select(banco.lancamentos)
          ..where((l) => l.descricao.equals('Mercado Atacadão'))
          ..orderBy([(l) => OrderingTerm.desc(l.id)])
          ..limit(1))
        .getSingle();
    expect((novo.valorCentavos, novo.dataLancamento, novo.mesFatura, novo.faturaManual), (
      10000,
      '2026-10-03',
      '2026-10',
      0,
    ));
    final completo = await banco.lancamentosDao.carregar(novo.id);
    expect(completo.categorias.map((p) => p.valorCentavos), [8000, 2000]);
    expect(completo.tags, ['atacado']);
    final tag = await (banco.select(banco.tags)..where((t) => t.nome.equals('atacado'))).get();
    expect(tag, hasLength(1));
  });
}
