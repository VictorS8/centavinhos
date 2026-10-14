# Centavinhos · arquivos da marca

Logo final: **peso de papel com a moeda com espessura**.

O logo tem três níveis de detalhe, escolhidos pelo tamanho em que aparece:

| Nível | Quando usar | O que muda |
|---|---|---|
| Completo | 72 px ou mais | Folhas com linhas de texto, brilho e serrilha na moeda |
| Simplificado | de 36 a 64 px | Sem as linhas de texto nem a serrilha |
| Mini | 32 px ou menos | Só três barrinhas e a moeda maior |

Os ícones do Windows já vêm com o nível certo em cada tamanho.

## O que tem em cada pasta

```
flutter/          copie o conteúdo para a raiz do projeto Flutter
  windows/runner/resources/app_icon.ico   ícone do .exe (16 a 256 px)
  assets/brand/                           logos usados dentro do app (1x, 2x e 3x)
  assets/pdf/                             logos em alta para o relatório em PDF
  assets/fonts/                           Libron e Roboto Flex (.ttf) com as licenças OFL
  msix/logo.png                           logo de 1024 px para o pacote msix
  lib/ui/brand/centavinhos_logo.dart      widgets prontos do logo
msix-assets/      conjunto completo de imagens do pacote MSIX (controle manual)
svg/              arquivos mestres em vetor (editar e gerar novos tamanhos)
png/              PNGs avulsos para site, redes e documentos
loja/             imagens para a página do app na Microsoft Store
```

## 1. Ícone do executável

Substitua o arquivo `windows/runner/resources/app_icon.ico` do seu projeto pelo que está em `flutter/windows/runner/resources/`. Depois rode `flutter clean` e `flutter build windows`.

## 2. Nome na janela e nas propriedades do .exe

Em `windows/runner/main.cpp`, troque o título da janela:

```cpp
if (!window.Create(L"Centavinhos", origin, size)) {
```

Em `windows/runner/Runner.rc`, ajuste estes valores:

```
VALUE "FileDescription", "Centavinhos" "\0"
VALUE "ProductName", "Centavinhos" "\0"
```

## 3. Logos dentro do app

No `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/brand/
    - assets/pdf/
    - assets/fonts/
  fonts:
    - family: Libron
      fonts:
        - asset: assets/fonts/Libron-Regular.ttf
        - asset: assets/fonts/Libron-Italic.ttf
          style: italic
        - asset: assets/fonts/Libron-Bold.ttf
          weight: 700
        - asset: assets/fonts/Libron-BoldItalic.ttf
          weight: 700
          style: italic
    - family: RobotoFlex
      fonts:
        - asset: assets/fonts/RobotoFlex-Regular.ttf
        - asset: assets/fonts/RobotoFlex-Medium.ttf
          weight: 500
        - asset: assets/fonts/RobotoFlex-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/RobotoFlex-Bold.ttf
          weight: 700
```

A Roboto Flex original é uma fonte variável. Os quatro pesos aqui foram gerados a partir dela (tamanho óptico 14), para o Flutter escolher o peso sem configuração extra.

As pastas `2.0x` e `3.0x` são achadas sozinhas pelo Flutter, conforme a escala do monitor.

Na barra lateral (no lugar do "C" provisório):

```dart
import 'ui/brand/centavinhos_logo.dart';

NavigationRail(
  leading: const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: CentavinhosLogo(size: 40),
  ),
  // ...
)
```

Logo com o nome, seguindo o tema escolhido nas Configurações:

```dart
CentavinhosLogoHorizontal(
  height: 32,
  brightness: Theme.of(context).brightness,
)
```

## 4. Logo no relatório em PDF

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

final logoBytes = (await rootBundle.load('assets/pdf/logo_horizontal.png'))
    .buffer
    .asUint8List();
final logo = pw.MemoryImage(logoBytes);

// no cabeçalho do relatório
pw.Image(logo, height: 22);
```

## 5. Pacote MSIX para a Microsoft Store

Copie `flutter/msix/logo.png` para a pasta `msix/` na raiz do projeto e adicione ao `pubspec.yaml`:

```yaml
dev_dependencies:
  msix: ^3.18.0

msix_config:
  display_name: Centavinhos
  publisher_display_name: Seu nome ou empresa
  identity_name: SeuEditor.Centavinhos   # copie do Partner Center
  msix_version: 1.0.0.0
  logo_path: msix/logo.png
  languages: pt-BR
  store: true
```

Gere com `dart run msix:create`.

A pasta `msix-assets/` traz o conjunto completo com os nomes do manifesto (`Square44x44Logo.targetsize-*`, as versões `_altform-unplated` e `_altform-lightunplated`, os tiles, a `StoreLogo` e a `SplashScreen` em 100, 125, 150, 200 e 400%). Use essa pasta se quiser montar o manifesto à mão ou se o ícone aparecer com fundo (backplate) na barra de tarefas.

## Cores

| Uso | Cor |
|---|---|
| Moeda | #2E9E78 |
| Borda da moeda | #1F6F5C |
| Lateral da moeda | #17594A |
| Brilho | #8FD9BC |
| Folha da frente | #FBF6EC |
| Folhas de trás | #F3E2C4 e #F7EBD5 |
| Contorno das folhas | #C9AE85 |
| Barra de destaque | #B57A55 |
| Título da folha | #6F4A33 |

A letra C e o nome usam a fonte Libron Bold, convertida em vetor. Os arquivos não dependem da fonte instalada.
