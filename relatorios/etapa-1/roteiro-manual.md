# Roteiro manual · Etapa 1

> Abra com `flutter run -d windows`. Se o app já foi usado antes, vá em Ajustes → "Apagar tudo e voltar às boas-vindas" para começar do zero.

## Janela

- [ x ] A barra de título mostra "Centavinhos" com o ícone do peso de papel, e o mesmo ícone aparece na barra de tarefas.
- [ x ] Ao tentar diminuir a janela, ela para em 1000 × 680.

## Boas-vindas

- [ x ] Abre com o logo, "Boas-vindas ao Centavinhos" e uma conta "Carteira" já preenchida.
- [ x ] No "Saldo hoje", digite 1, 2, 5 e 0: o campo mostra R$ 0,01, R$ 0,12, R$ 1,25 e R$ 12,50.
- [ x ] Backspace volta para R$ 1,25. Vírgula e ponto não fazem nada.
- [ x ] Aperte "-": vira −R$ 1,25. Aperte "-" de novo: volta para R$ 1,25.
- [ x ] Copie o texto `1.234,56` e cole no campo com Ctrl+V: mostra R$ 1.234,56.
- [ x ] Apague o nome da Carteira: o botão "Começar" trava e aparece "Dê um nome a cada conta.". Escreva o nome de novo.
- [ x ] Em "Adicionar conta", cadastre "Nubank", tipo Banco, com saldo −R$ 200,00.
- [ x ] Em "Adicionar cartão", preencha "Nubank", fechamento 5 e vencimento 12, sem escolher a conta: aparece "Escolha a conta que paga cada cartão.".
- [ x ] Em "Pago pela conta", aparecem só Carteira e Nubank. Escolha Nubank.
- [ x ] Troque o fechamento para 0 ou 32: aparece "Fechamento e vencimento vão de 1 a 31.". Volte para 5.
- [ x ] Usando só o Tab, passe por todos os campos: a ordem segue a da tela, da esquerda para a direita e de cima para baixo.
- [ x ] Com o Tab, pare em "Adicionar conta" e depois em "Começar": cada botão ganha um contorno grosso em volta (escuro no modo claro, claro no modo escuro), fácil de ver.
- [ x ] Clique em "Começar": abre a tela do mês com o mês atual (ex.: "Outubro 2026").

## Tela principal

- [ x ] A barra lateral tem o logo, o botão +, Mês, Filtros, Cartões, Cadastros e Ajustes. Cada destino abre a sua tela com "Esta tela chega na etapa N.".
- [ x ] Ctrl+N ou o botão + abrem o aviso "Novo lançamento". Esc fecha.
- [ x ] Aperte Tab até o botão +: ele ganha o mesmo contorno grosso dos outros botões. Enter abre o aviso.
- [ x ] Feche e abra o app de novo: ele vai direto para a tela do mês, sem as boas-vindas.

## Tema

- [ x ] Troque o Windows entre claro e escuro (Configurações → Personalização → Cores → Escolha o modo): o app acompanha na hora.

## Ferramentas de desenvolvimento

> Só aparecem rodando com `flutter run`.

- [ x ] Ajustes → "Apagar tudo e voltar às boas-vindas" → "Apagar tudo": o app volta para as boas-vindas.
- [ x ] Nas boas-vindas, "Preencher com dados de exemplo" vai direto para a tela do mês. Os lançamentos de exemplo só aparecem na tela a partir da etapa 4.
- [ x ] Ajustes → "Recriar dados de exemplo" → "Apagar tudo": continua na tela do mês, sem erro.
