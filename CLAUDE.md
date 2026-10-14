# Centavinhos

App desktop de finanças pessoais para Windows, em Flutter. Toda a especificação está no escopo abaixo, carregado em toda sessão. Siga o que ele diz.

@docs/escopo-v1-centavinhos.md

## Como trabalhamos

- Uma etapa por vez, pela "Ordem de construção" do escopo. Quando eu pedir "faça a etapa N", faça só essa etapa.
- Antes de começar, diga em poucas linhas o que vai fazer. No fim, liste o que mudou e como testar.
- Toda etapa termina com `flutter analyze` e `flutter test` sem erros, e com o app abrindo no Windows.
- Se algo do escopo estiver ambíguo ou em conflito, pergunte antes de decidir.

## Regras que valem sempre

- Interface e textos em português do Brasil.
- Dinheiro sempre em centavos, como `int`. Nunca `double` para valores.
- Material 3 pelo pacote `material_ui` (`package:material_ui/material_ui.dart`).
- Toda cor vem de `Theme.of(context).colorScheme` ou da extensão de aviso do tema. Nenhuma cor escrita direto num componente.
- Fontes: Libron para títulos e valores, Roboto Flex para rótulos e textos, com números de largura fixa (`FontFeature.tabularFigures()`).
- Regras de negócio puras em `lib/domain/`, sem Flutter, cada uma com teste unitário.
- Telas de referência em `docs/telas/`. Siga o layout, mas o tema do Material 3 manda nas cores exatas.

## Arquivos que não devem ser alterados

- `marca/`: pacote original da marca. Na etapa 1, copie o conteúdo de `marca/flutter/` para a raiz do projeto, juntando as pastas, e siga `marca/LEIA-ME.md`.
- `docs/`: só eu altero o escopo. Se uma etapa pedir mudança nele, sugira o texto.
