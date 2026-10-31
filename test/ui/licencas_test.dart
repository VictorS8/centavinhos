import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/licencas.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('pt_BR'));
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    LicenseRegistry.reset();
    registrarLicencasDasFontes();
  });
  tearDown(() {
    LicenseRegistry.reset();
    return db.close();
  });

  Future<void> abrirAjustes(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(
      () => db.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bancoProvider.overrideWithValue(db)],
        child: const CentavinhosApp(),
      ),
    );
    // O banco responde fora do relógio falso dos testes.
    await tester.runAsync(() => db.observarConfiguracoes().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes').last);
    await tester.pumpAndSettle();
  }

  Future<void> fecharApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// Espera a tela de licenças ler os arquivos das fontes, que vêm de fora
  /// do relógio falso dos testes.
  Future<void> esperarLicencas(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Ajustes mostra a licença e o botão Licenças', (tester) async {
    await abrirAjustes(tester);
    expect(find.text('Sobre'), findsOneWidget);
    expect(
      find.text('O Centavinhos é licenciado sob a Apache License 2.0.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Licenças'), findsOneWidget);
    await fecharApp(tester);
  });

  testWidgets('Licenças mostra o Centavinhos e as duas fontes', (tester) async {
    await abrirAjustes(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Licenças'));
    await esperarLicencas(tester);

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text('Centavinhos'), findsWidgets);
    expect(find.textContaining('João Victor das Neves Sousa Almeida'), findsOneWidget);
    expect(find.textContaining('Licenciado sob a Apache License 2.0'), findsOneWidget);
    // Na janela larga, o nome também aparece no título do item aberto.
    expect(find.text('Fonte Libron'), findsWidgets);
    expect(find.text('Fonte Roboto Flex'), findsWidgets);

    await tester.tap(find.text('Fonte Libron').first);
    await esperarLicencas(tester);
    expect(find.textContaining('Reserved Font Name Libron'), findsWidgets);
    await fecharApp(tester);
  });
}
