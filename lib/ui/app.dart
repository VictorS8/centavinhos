import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/providers.dart';
import 'casca_principal.dart';
import 'telas/tela_boas_vindas.dart';
import 'theme/app_theme.dart';
import 'theme/tema_cor.dart';
import 'theme/tema_provider.dart';

class CentavinhosApp extends ConsumerWidget {
  const CentavinhosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escolha = ref.watch(temaEscolhidoProvider);
    final corDoSistema = escolha.cor == TemaCor.sistema
        ? ref.watch(corDoSistemaProvider).value
        : null;

    return MaterialApp(
      title: 'Centavinhos',
      debugShowCheckedModeBanner: false,
      theme: construirTema(escolha.cor, Brightness.light, corDoSistema: corDoSistema),
      darkTheme: construirTema(escolha.cor, Brightness.dark, corDoSistema: corDoSistema),
      themeMode: escolha.modo,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _Inicio(),
    );
  }
}

/// Mostra as boas-vindas na primeira abertura e a tela principal depois.
class _Inicio extends ConsumerWidget {
  const _Inicio();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(boasVindasConcluidaProvider)) {
      AsyncData(value: true) => const CascaPrincipal(),
      AsyncData() => const TelaBoasVindas(),
      AsyncError(:final error) => Scaffold(
        body: Center(child: Text('Não foi possível abrir o banco de dados.\n$error')),
      ),
      _ => const Scaffold(),
    };
  }
}
