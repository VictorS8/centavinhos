import 'package:material_ui/material_ui.dart';

/// Cor de aviso do tema, usada na etiqueta "Atenção" e no ícone da faixa de
/// alerta de saldo. Pegue com `Theme.of(context).extension<AvisoColors>()!`.
@immutable
class AvisoColors extends ThemeExtension<AvisoColors> {
  const AvisoColors({required this.avisoContainer, required this.onAvisoContainer});

  /// Fundo da etiqueta e do ícone de aviso.
  final Color avisoContainer;

  /// Texto e ícone sobre [avisoContainer].
  final Color onAvisoContainer;

  @override
  AvisoColors copyWith({Color? avisoContainer, Color? onAvisoContainer}) => AvisoColors(
    avisoContainer: avisoContainer ?? this.avisoContainer,
    onAvisoContainer: onAvisoContainer ?? this.onAvisoContainer,
  );

  @override
  AvisoColors lerp(AvisoColors? other, double t) {
    if (other == null) return this;
    return AvisoColors(
      avisoContainer: Color.lerp(avisoContainer, other.avisoContainer, t)!,
      onAvisoContainer: Color.lerp(onAvisoContainer, other.onAvisoContainer, t)!,
    );
  }
}
