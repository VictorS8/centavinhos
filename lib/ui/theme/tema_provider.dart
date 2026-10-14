import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/configuracoes.dart';
import '../../data/providers.dart';
import 'tema_cor.dart';

/// Cor de destaque do Windows, lida pelo `dynamic_color`. Nula quando o
/// sistema não informa.
final corDoSistemaProvider = FutureProvider<Color?>((ref) async {
  try {
    return await DynamicColorPlugin.getAccentColor();
  } catch (_) {
    return null;
  }
});

/// Cor e modo escolhidos, lidos da tabela de configurações.
final temaEscolhidoProvider = Provider<({TemaCor cor, ThemeMode modo})>((ref) {
  final configuracoes = ref.watch(configuracoesProvider).value ?? const {};
  return (
    cor: TemaCor.deValor(configuracoes[ChaveConfiguracao.temaCor]),
    modo: modoDeValor(configuracoes[ChaveConfiguracao.temaModo]),
  );
});
