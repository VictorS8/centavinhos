import 'package:centavinhos/ui/theme/app_theme.dart';
import 'package:centavinhos/ui/theme/aviso_colors.dart';
import 'package:centavinhos/ui/theme/tema_cor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // Tabela "Cores fixas do tema" do escopo: primária, container primário,
  // container terciário / texto, container de aviso / texto.
  const tabela = {
    (TemaCor.verde, Brightness.light): [0xFF1F6F5C, 0xFFA6F2DB, 0xFFC5E7FF, 0xFF001E2D, 0xFFF0E3A2, 0xFF221B00],
    (TemaCor.verde, Brightness.dark): [0xFF8AD6BF, 0xFF005142, 0xFF284B5F, 0xFFC5E7FF, 0xFF524700, 0xFFF0E3A2],
    (TemaCor.roxo, Brightness.light): [0xFF6750A4, 0xFFEADDFF, 0xFFB8EDE9, 0xFF00201F, 0xFFFFDBC8, 0xFF2E1500],
    (TemaCor.roxo, Brightness.dark): [0xFFD0BCFF, 0xFF4F378B, 0xFF1F4E4C, 0xFFB8EDE9, 0xFF6A3C17, 0xFFFFDBC8],
    (TemaCor.azul, Brightness.light): [0xFF2F5DA9, 0xFFD8E2FF, 0xFFFAD8FD, 0xFF28132E, 0xFFFFE0BC, 0xFF2A1800],
    (TemaCor.azul, Brightness.dark): [0xFFADC6FF, 0xFF2B4678, 0xFF583E5B, 0xFFFAD8FD, 0xFF633F12, 0xFFFFE0BC],
  };

  for (final MapEntry(key: (cor, brilho), value: cores) in tabela.entries) {
    final modo = brilho == Brightness.light ? 'claro' : 'escuro';
    test('${cor.name} $modo segue a tabela do escopo', () {
      final tema = construirTema(cor, brilho);
      final esquema = tema.colorScheme;
      final aviso = tema.extension<AvisoColors>()!;

      expect(esquema.brightness, brilho);
      expect(esquema.primary, Color(cores[0]));
      expect(esquema.primaryContainer, Color(cores[1]));
      expect(esquema.tertiaryContainer, Color(cores[2]));
      expect(esquema.onTertiaryContainer, Color(cores[3]));
      expect(aviso.avisoContainer, Color(cores[4]));
      expect(aviso.onAvisoContainer, Color(cores[5]));
    });
  }

  test('cor do sistema usa a cor de destaque e harmoniza o aviso', () {
    const destaque = Color(0xFF0078D4);
    final tema = construirTema(TemaCor.sistema, Brightness.light, corDoSistema: destaque);
    final aviso = tema.extension<AvisoColors>()!;

    final daSemente = ColorScheme.fromSeed(seedColor: destaque);
    expect(tema.colorScheme.primary, daSemente.primary);
    // Harmonizado, o amarelo de partida muda de tom.
    expect(aviso.avisoContainer, isNot(const Color(0xFFF0E3A2)));
  });

  test('cor do sistema sem cor de destaque cai no verde', () {
    final tema = construirTema(TemaCor.sistema, Brightness.light);
    expect(tema.colorScheme.primary, const Color(0xFF1F6F5C));
  });

  test('fontes: Libron nos títulos, Roboto Flex nos textos, números fixos', () {
    final textos = construirTema(TemaCor.verde, Brightness.light).textTheme;
    for (final estilo in [textos.displayLarge, textos.headlineMedium, textos.titleLarge]) {
      expect(estilo!.fontFamily, 'Libron');
      expect(estilo.fontFeatures, contains(const FontFeature.tabularFigures()));
    }
    for (final estilo in [textos.titleMedium, textos.bodyLarge, textos.labelLarge]) {
      expect(estilo!.fontFamily, 'RobotoFlex');
      expect(estilo.fontFeatures, contains(const FontFeature.tabularFigures()));
    }
  });

  group('anel de foco', () {
    const focado = {WidgetState.focused};
    const normal = <WidgetState>{};

    for (final brilho in Brightness.values) {
      test('aparece em todos os botões só com foco (${brilho.name})', () {
        final tema = construirTema(TemaCor.verde, brilho);
        final anel = anelDeFoco(tema.colorScheme);
        expect(anel.color, tema.colorScheme.onSurface);
        expect(anel.width, 3);
        expect(anel.strokeAlign, BorderSide.strokeAlignOutside);

        for (final estilo in [
          tema.filledButtonTheme.style,
          tema.elevatedButtonTheme.style,
          tema.textButtonTheme.style,
          tema.iconButtonTheme.style,
        ]) {
          expect(estilo!.side!.resolve(focado), anel);
          expect(estilo.side!.resolve(normal), isNull);
          expect(estilo.side!.resolve({WidgetState.focused, WidgetState.disabled}), isNull);
        }

        final contorno = tema.outlinedButtonTheme.style!.side!;
        expect(contorno.resolve(focado), anel);
        expect(contorno.resolve(normal), BorderSide(color: tema.colorScheme.outline));

        final formatoMais = tema.floatingActionButtonTheme.shape;
        final comFoco = WidgetStateProperty.resolveAs<ShapeBorder?>(formatoMais, focado);
        final semFoco = WidgetStateProperty.resolveAs<ShapeBorder?>(formatoMais, normal);
        expect((comFoco! as OutlinedBorder).side, anel);
        expect((semFoco! as OutlinedBorder).side, BorderSide.none);
      });
    }
  });

  test('valores guardados no banco', () {
    expect(TemaCor.deValor('roxo'), TemaCor.roxo);
    expect(TemaCor.deValor('desconhecido'), TemaCor.verde);
    expect(TemaCor.deValor(null), TemaCor.verde);
    expect(modoDeValor('claro'), ThemeMode.light);
    expect(modoDeValor('escuro'), ThemeMode.dark);
    expect(modoDeValor('sistema'), ThemeMode.system);
  });
}
