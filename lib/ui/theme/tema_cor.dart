import 'package:material_ui/material_ui.dart';

/// As quatro opções de cor do tema, como ficam na configuração `tema_cor`.
enum TemaCor {
  verde,
  roxo,
  azul,
  sistema;

  /// Lê o valor guardado no banco. Valor desconhecido vira verde.
  static TemaCor deValor(String? valor) =>
      values.firstWhere((cor) => cor.name == valor, orElse: () => verde);
}

/// Modo claro ou escuro, como fica na configuração `tema_modo`.
ThemeMode modoDeValor(String? valor) => switch (valor) {
  'claro' => ThemeMode.light,
  'escuro' => ThemeMode.dark,
  _ => ThemeMode.system,
};
