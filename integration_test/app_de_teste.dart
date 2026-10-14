import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Data fixa dos testes, a dos exemplos do escopo.
final hojeDosTestes = DateTime(2026, 10, 12);

/// Prepara o binding dos testes de integração e o português das datas.
void prepararTestesDeIntegracao() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR');
  });
}

/// Abre o Centavinhos de verdade, com um banco em memória (o banco real em
/// %APPDATA% nunca é tocado) e a data fixa em [hojeDosTestes]. Devolve o
/// banco para o teste conferir o que foi gravado.
Future<AppDatabase> abrirApp(WidgetTester tester) async {
  final banco = AppDatabase(NativeDatabase.memory());
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await banco.close();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bancoProvider.overrideWithValue(banco),
        hojeProvider.overrideWithValue(hojeDosTestes),
      ],
      child: const CentavinhosApp(),
    ),
  );
  await tester.pumpAndSettle();
  return banco;
}

/// Campo de texto pelo rótulo. Com mais de um igual, use [posicao].
Finder campo(String rotulo, {int posicao = 0}) =>
    find.widgetWithText(TextField, rotulo).at(posicao);

/// Digita [teclas] uma a uma no campo, como no teclado, passando pelos
/// formatadores do campo (o valor estilo caixa eletrônico depende disso).
Future<void> digitar(WidgetTester tester, Finder alvo, List<String> teclas) async {
  await tester.tap(alvo);
  await tester.pump();
  final editavel = find.descendant(of: alvo, matching: find.byType(EditableText));
  for (final tecla in teclas) {
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

/// Texto que está dentro de um campo.
String textoDoCampo(WidgetTester tester, Finder alvo) => tester
    .widget<EditableText>(find.descendant(of: alvo, matching: find.byType(EditableText)))
    .controller
    .text;

/// Aperta um atalho com Ctrl, como Ctrl+N.
Future<void> apertarCtrl(WidgetTester tester, LogicalKeyboardKey tecla) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(tecla);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}
