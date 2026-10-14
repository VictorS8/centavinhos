import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';

import 'aviso_colors.dart';
import 'tema_cor.dart';

/// Cores fixas de uma combinação de cor e modo, da tabela "Cores fixas do
/// tema" do escopo. O `ColorScheme.fromSeed` gera o resto.
class _CoresFixas {
  const _CoresFixas({
    required this.primaria,
    required this.containerPrimario,
    required this.containerTerciario,
    required this.textoTerciario,
    required this.containerAviso,
    required this.textoAviso,
  });

  final Color primaria;
  final Color containerPrimario;
  final Color containerTerciario;
  final Color textoTerciario;
  final Color containerAviso;
  final Color textoAviso;
}

/// Cor principal de cada opção fixa, usada como semente.
const _sementes = {
  TemaCor.verde: Color(0xFF1F6F5C),
  TemaCor.roxo: Color(0xFF6750A4),
  TemaCor.azul: Color(0xFF2F5DA9),
};

const _coresFixas = {
  (TemaCor.verde, Brightness.light): _CoresFixas(
    primaria: Color(0xFF1F6F5C),
    containerPrimario: Color(0xFFA6F2DB),
    containerTerciario: Color(0xFFC5E7FF),
    textoTerciario: Color(0xFF001E2D),
    containerAviso: Color(0xFFF0E3A2),
    textoAviso: Color(0xFF221B00),
  ),
  (TemaCor.verde, Brightness.dark): _CoresFixas(
    primaria: Color(0xFF8AD6BF),
    containerPrimario: Color(0xFF005142),
    containerTerciario: Color(0xFF284B5F),
    textoTerciario: Color(0xFFC5E7FF),
    containerAviso: Color(0xFF524700),
    textoAviso: Color(0xFFF0E3A2),
  ),
  (TemaCor.roxo, Brightness.light): _CoresFixas(
    primaria: Color(0xFF6750A4),
    containerPrimario: Color(0xFFEADDFF),
    containerTerciario: Color(0xFFB8EDE9),
    textoTerciario: Color(0xFF00201F),
    containerAviso: Color(0xFFFFDBC8),
    textoAviso: Color(0xFF2E1500),
  ),
  (TemaCor.roxo, Brightness.dark): _CoresFixas(
    primaria: Color(0xFFD0BCFF),
    containerPrimario: Color(0xFF4F378B),
    containerTerciario: Color(0xFF1F4E4C),
    textoTerciario: Color(0xFFB8EDE9),
    containerAviso: Color(0xFF6A3C17),
    textoAviso: Color(0xFFFFDBC8),
  ),
  (TemaCor.azul, Brightness.light): _CoresFixas(
    primaria: Color(0xFF2F5DA9),
    containerPrimario: Color(0xFFD8E2FF),
    containerTerciario: Color(0xFFFAD8FD),
    textoTerciario: Color(0xFF28132E),
    containerAviso: Color(0xFFFFE0BC),
    textoAviso: Color(0xFF2A1800),
  ),
  (TemaCor.azul, Brightness.dark): _CoresFixas(
    primaria: Color(0xFFADC6FF),
    containerPrimario: Color(0xFF2B4678),
    containerTerciario: Color(0xFF583E5B),
    textoTerciario: Color(0xFFFAD8FD),
    containerAviso: Color(0xFF633F12),
    textoAviso: Color(0xFFFFE0BC),
  ),
};

/// Amarelo de partida do aviso na cor do sistema, antes de harmonizar.
const _avisoSistema = {
  Brightness.light: (container: Color(0xFFF0E3A2), texto: Color(0xFF221B00)),
  Brightness.dark: (container: Color(0xFF524700), texto: Color(0xFFF0E3A2)),
};

/// Monta o tema do app para uma cor e um modo.
///
/// Na [TemaCor.sistema], usa [corDoSistema] (a cor de destaque do Windows)
/// como semente; sem ela, cai no verde.
ThemeData construirTema(TemaCor cor, Brightness brilho, {Color? corDoSistema}) {
  final ColorScheme esquema;
  final AvisoColors aviso;

  if (cor == TemaCor.sistema && corDoSistema != null) {
    esquema = ColorScheme.fromSeed(seedColor: corDoSistema, brightness: brilho);
    final partida = _avisoSistema[brilho]!;
    aviso = AvisoColors(
      avisoContainer: partida.container.harmonizeWith(esquema.primary),
      onAvisoContainer: partida.texto.harmonizeWith(esquema.primary),
    );
  } else {
    final corFixa = cor == TemaCor.sistema ? TemaCor.verde : cor;
    final fixas = _coresFixas[(corFixa, brilho)]!;
    final base = ColorScheme.fromSeed(seedColor: _sementes[corFixa]!, brightness: brilho);
    // A família terciária é gerada a partir do container terciário da
    // tabela, para manter o tom escolhido à mão (ex.: azul claro no verde).
    final terciaria = ColorScheme.fromSeed(
      seedColor: fixas.containerTerciario,
      brightness: brilho,
    );
    esquema = base.copyWith(
      primary: fixas.primaria,
      primaryContainer: fixas.containerPrimario,
      tertiary: terciaria.primary,
      onTertiary: terciaria.onPrimary,
      tertiaryContainer: fixas.containerTerciario,
      onTertiaryContainer: fixas.textoTerciario,
    );
    aviso = AvisoColors(
      avisoContainer: fixas.containerAviso,
      onAvisoContainer: fixas.textoAviso,
    );
  }

  final tema = ThemeData(colorScheme: esquema, fontFamily: 'RobotoFlex');
  final anel = anelDeFoco(esquema);
  return tema.copyWith(
    textTheme: _tipografia(tema.textTheme),
    filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(side: _borda(anel))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(side: _borda(anel))),
    textButtonTheme: TextButtonThemeData(style: ButtonStyle(side: _borda(anel))),
    iconButtonTheme: IconButtonThemeData(style: ButtonStyle(side: _borda(anel))),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(side: _borda(anel, contorno: esquema)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(shape: _FormatoComFoco(anel)),
    extensions: [aviso],
  );
}

/// Anel de foco dos botões: 3 px de `onSurface` por fora, como o indicador
/// de foco do Material 3. Sem ele, o foco pelo Tab só clareia 10% do botão,
/// o que quase não aparece num botão preenchido.
BorderSide anelDeFoco(ColorScheme esquema) => BorderSide(
  color: esquema.onSurface,
  width: 3,
  strokeAlign: BorderSide.strokeAlignOutside,
);

/// Borda dos botões: o [anel] com foco. Sem foco, nenhuma borda, ou o
/// contorno padrão do Material 3 quando o botão é de [contorno].
WidgetStateProperty<BorderSide?> _borda(BorderSide anel, {ColorScheme? contorno}) =>
    WidgetStateProperty.resolveWith((estados) {
      final desativado = estados.contains(WidgetState.disabled);
      if (estados.contains(WidgetState.focused) && !desativado) return anel;
      if (contorno == null) return null;
      return BorderSide(
        color: desativado ? contorno.onSurface.withValues(alpha: 0.12) : contorno.outline,
      );
    });

/// Formato do botão +: o canto de 16 px do Material 3, com o [anel] quando
/// tem foco. O botão + não aceita borda por estado, só o formato.
class _FormatoComFoco extends RoundedRectangleBorder implements WidgetStateOutlinedBorder {
  const _FormatoComFoco(this.anel)
    : super(borderRadius: const BorderRadius.all(Radius.circular(16)));

  final BorderSide anel;

  @override
  OutlinedBorder resolve(Set<WidgetState> estados) =>
      estados.contains(WidgetState.focused) ? copyWith(side: anel) : this;
}

const _numerosFixos = [FontFeature.tabularFigures()];

/// Libron nos papéis de marca (display, headline e título grande) e
/// Roboto Flex nos neutros, com números de largura fixa nas duas.
TextTheme _tipografia(TextTheme base) {
  TextStyle? marca(TextStyle? estilo) =>
      estilo?.copyWith(fontFamily: 'Libron', fontFeatures: _numerosFixos);
  TextStyle? neutra(TextStyle? estilo) =>
      estilo?.copyWith(fontFamily: 'RobotoFlex', fontFeatures: _numerosFixos);

  return base.copyWith(
    displayLarge: marca(base.displayLarge),
    displayMedium: marca(base.displayMedium),
    displaySmall: marca(base.displaySmall),
    headlineLarge: marca(base.headlineLarge),
    headlineMedium: marca(base.headlineMedium),
    headlineSmall: marca(base.headlineSmall),
    titleLarge: marca(base.titleLarge),
    titleMedium: neutra(base.titleMedium),
    titleSmall: neutra(base.titleSmall),
    bodyLarge: neutra(base.bodyLarge),
    bodyMedium: neutra(base.bodyMedium),
    bodySmall: neutra(base.bodySmall),
    labelLarge: neutra(base.labelLarge),
    labelMedium: neutra(base.labelMedium),
    labelSmall: neutra(base.labelSmall),
  );
}
