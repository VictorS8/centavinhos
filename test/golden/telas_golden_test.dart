// Capturas das telas em test/golden/capturas/. Se uma tela mudar, o teste
// falha e mostra a diferença em test/golden/failures/. Quando a mudança for de
// propósito, gere as capturas de novo com:
//   flutter test --update-goldens test/golden

import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'fontes.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
    await carregarFontesDoApp();
  });
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Abre o app com a cor e o modo pedidos, vai até [destino] na barra
  /// lateral (se houver) e compara com a captura [nome].
  Future<void> capturar(
    WidgetTester tester,
    String nome, {
    String cor = 'verde',
    String modo = 'claro',
    bool boasVindasConcluida = false,
    String? destino,
  }) async {
    await tester.runAsync(() async {
      await db.definirConfiguracao(ChaveConfiguracao.temaCor, cor);
      await db.definirConfiguracao(ChaveConfiguracao.temaModo, modo);
      if (boasVindasConcluida) {
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
    await tester.runAsync(() => db.observarConfiguracoes().first);
    await tester.pumpAndSettle();
    if (destino != null) {
      await tester.tap(find.text(destino).last);
      await tester.pumpAndSettle();
    }

    // Os logos são imagens: precisam ser lidas antes da captura.
    await tester.runAsync(() async {
      for (final elemento in find.byType(Image).evaluate()) {
        await precacheImage((elemento.widget as Image).image, elemento);
      }
    });
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/$nome.png'));

    // Desmonta antes de fechar o banco, para encerrar os fluxos do Drift.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('boas-vindas, verde claro', (tester) async {
    await capturar(tester, 'boas_vindas_verde_claro');
  });

  testWidgets('boas-vindas, verde escuro', (tester) async {
    await capturar(tester, 'boas_vindas_verde_escuro', modo: 'escuro');
  });

  testWidgets('boas-vindas, roxo escuro', (tester) async {
    await capturar(tester, 'boas_vindas_roxo_escuro', cor: 'roxo', modo: 'escuro');
  });

  testWidgets('tela do mês, verde claro', (tester) async {
    await capturar(tester, 'mes_verde_claro', boasVindasConcluida: true);
  });

  testWidgets('ajustes, verde claro', (tester) async {
    await capturar(
      tester,
      'ajustes_verde_claro',
      boasVindasConcluida: true,
      destino: 'Ajustes',
    );
  });
}
