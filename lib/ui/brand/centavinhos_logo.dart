import 'package:flutter/widgets.dart';

/// Logo do Centavinhos (peso de papel com a moeda com espessura).
///
/// Até 64 px usa a versão simplificada, que tira as linhas de texto da folha
/// para continuar legível. Acima disso usa a versão completa.
class CentavinhosLogo extends StatelessWidget {
  const CentavinhosLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = size <= 64
        ? 'assets/brand/logo_simplificado.png'
        : 'assets/brand/logo.png';
    return Image.asset(
      asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Centavinhos',
    );
  }
}

/// Logo com o nome ao lado, para cabeçalhos e telas de boas-vindas.
///
/// Passe `brightness: Theme.of(context).brightness` para seguir o tema
/// escolhido nas Configurações. Sem ele, segue o tema do Windows.
class CentavinhosLogoHorizontal extends StatelessWidget {
  const CentavinhosLogoHorizontal({super.key, this.height = 32, this.brightness});

  final double height;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness ?? MediaQuery.platformBrightnessOf(context);
    final escuro = b == Brightness.dark;
    return Image.asset(
      escuro
          ? 'assets/brand/logo_horizontal_escuro.png'
          : 'assets/brand/logo_horizontal.png',
      height: height,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Centavinhos',
    );
  }
}
