import 'dart:convert';

import 'package:flutter/services.dart';

/// Carrega nos testes as fontes declaradas no app (Libron, Roboto Flex e os
/// ícones do Material). Sem isso, os testes desenham todo texto como
/// quadradinhos.
Future<void> carregarFontesDoApp() async {
  final manifesto = json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final familia in manifesto.cast<Map<String, dynamic>>()) {
    final carregador = FontLoader(familia['family'] as String);
    for (final fonte in (familia['fonts'] as List).cast<Map<String, dynamic>>()) {
      carregador.addFont(rootBundle.load(fonte['asset'] as String));
    }
    await carregador.load();
  }
}
