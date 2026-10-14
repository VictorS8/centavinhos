import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/casca_principal.dart';
import 'package:centavinhos/ui/telas/tela_boas_vindas.dart';
import 'package:centavinhos/ui/widgets/campo_valor.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('pt_BR'));
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bancoProvider.overrideWithValue(db)],
        child: const CentavinhosApp(),
      ),
    );
    // O banco responde fora do relógio falso dos testes.
    await tester.runAsync(() => db.observarConfiguracoes().first);
    await tester.pumpAndSettle();
  }

  Future<void> fecharApp(WidgetTester tester) async {
    // Desmonta antes de fechar o banco, para encerrar os fluxos do Drift.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('banco novo abre nas boas-vindas', (tester) async {
    await abrirApp(tester);
    expect(find.byType(TelaBoasVindas), findsOneWidget);
    expect(find.text('Boas-vindas ao Centavinhos'), findsOneWidget);
    await fecharApp(tester);
  });

  testWidgets('com as boas-vindas concluídas, abre na tela do mês', (tester) async {
    await tester.runAsync(
      () => db.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1'),
    );
    await abrirApp(tester);
    expect(find.byType(CascaPrincipal), findsOneWidget);
    for (final destino in ['Mês', 'Filtros', 'Cartões', 'Cadastros', 'Ajustes']) {
      expect(find.text(destino), findsWidgets);
    }
    await fecharApp(tester);
  });

  testWidgets('saldo: digitar 2, 0, 0, 0, 0 e "-" mostra −R\$ 200,00', (tester) async {
    await abrirApp(tester);

    final campo = find.descendant(
      of: find.byType(CampoValor),
      matching: find.byType(EditableText),
    );
    expect(campo, findsOneWidget);
    await tester.showKeyboard(campo);

    for (final tecla in ['2', '0', '0', '0', '0', '-']) {
      final atual = tester.widget<EditableText>(campo).controller.text;
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '$atual$tecla',
          selection: TextSelection.collapsed(offset: atual.length + 1),
        ),
      );
      await tester.pump();
    }

    expect(find.text('−R\$ 200,00'), findsOneWidget);
    expect(find.text('Aperte - para negativo'), findsOneWidget);
    await fecharApp(tester);
  });

  test('formatador: backspace, vírgula e texto colado', () {
    final formatador = FormatadorCaixaEletronico(permiteNegativo: false);
    TextEditingValue editar(String antes, String depois) => formatador.formatEditUpdate(
      TextEditingValue(text: antes),
      TextEditingValue(text: depois),
    );

    expect(editar('R\$ 12,50', 'R\$ 12,5').text, 'R\$ 1,25');
    expect(editar('R\$ 1,25', 'R\$ 1,25,').text, 'R\$ 1,25');
    expect(editar('R\$ 0,00', 'R\$ 0,0012,50').text, 'R\$ 12,50');
    // Tudo selecionado e trocado por um número começa do zero.
    expect(editar('R\$ 12,50', '7').text, 'R\$ 0,07');
  });
}
