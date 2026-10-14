# Centavinhos

App desktop de finanças pessoais para Windows, em Flutter. Toda a especificação está no escopo abaixo, carregado em toda sessão. Siga o que ele diz.

@docs/escopo-v1-centavinhos.md

O andamento das etapas e o que mudou em relação ao escopo ficam no `PROGRESSO.md`, também carregado em toda sessão. Quando ele e o escopo divergirem, vale o `PROGRESSO.md`.

@PROGRESSO.md

## Como trabalhamos

- Uma etapa por vez, pela "Ordem de construção" do escopo. Quando eu pedir "faça a etapa N", faça só essa etapa.
- Antes de começar, diga em poucas linhas o que vai fazer. No fim, liste o que mudou e como testar.
- Se algo do escopo estiver ambíguo ou em conflito, pergunte antes de decidir.
- Toda etapa cobre o que fez com testes em três níveis:
  - testes rápidos em `test/` (regras, banco e interface);
  - capturas de tela das telas novas ou alteradas em `test/golden/` (gerar com `flutter test --update-goldens test/golden` só quando a mudança visual for de propósito);
  - um ou dois testes de integração em `integration_test/` com os fluxos principais da etapa, usando `abrirApp` (banco em memória e data fixa em 12/10/2026). Nunca simule cliques ou teclas no Windows fora dos testes.
- Ao fechar uma etapa:
  1. Escreva `relatorios/etapa-N/roteiro-manual.md`: os fluxos principais para testar na mão, em caixas de marcar, cada uma com o que fazer e o que deve aparecer.
  2. Rode `dart run tool/relatorio.dart N`. Ele roda o `flutter analyze`, os testes, as capturas e a integração, e gera `relatorios/etapa-N/index.html`. A etapa só termina com ele sem falhas.
  3. Atualize o `PROGRESSO.md`: marque a etapa e anote cada diferença em relação ao escopo e cada pendência para as próximas.

## Commits

- Nunca faça commit sem eu revisar e aprovar antes.
- Quando eu pedir para organizar os commits, mostre a lista proposta antes de fazer qualquer um. Para cada commit:
  - a mensagem, no estilo do histórico (`tipo: descrição` em português, como `feat:`, `fix:`, `test:`, `docs:`, `chore:`);
  - os arquivos que entram;
  - o contexto: o que muda e por quê, em poucas linhas.
- Só faça os commits depois que eu aprovar a lista. Se eu pedir ajustes, mostre a lista de novo.

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
