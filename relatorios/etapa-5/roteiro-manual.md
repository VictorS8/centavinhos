# Roteiro manual · Etapa 5

> Abra com `flutter run -d windows`. Para ter dados para testar, vá em Ajustes → "Recriar dados de exemplo" (só no modo de desenvolvimento). Os exemplos ficam em volta do mês de hoje: as contas Carteira, Nubank e Inter, o cartão Nubank (fecha dia 5, vence dia 12), o cartão Inter (fecha dia 8, vence dia 15), "Fone Bluetooth" em 3 parcelas no Nubank, um estorno do "Restaurante" no Nubank e, novidade desta etapa, uma "Mochila" comprada no Inter no mês passado e devolvida (estorno) no dia 9 deste mês. Nos itens abaixo, "M" é o mês atual, "M+1" o seguinte e assim por diante.
>
> O "Ajustar pagamento" das faturas chega na etapa 7, junto com o saldo.

## Compra parcelada

- [x] Ctrl+N, nome "Fone novo", valor R$ 300,02. No campo Recorrência, escolha "Parcelada": aparece o campo "Parcelas" logo abaixo, e embaixo da janela o aviso "Parcelas vão de 2 a 48.".
- [x] Digite 3 em Parcelas: ao lado aparece "1x de R$ 100,02 e 2x de R$ 100,00". Com 49, o aviso volta; com o valor R$ 0,02 e 3 parcelas, aparece "O valor não dá R$ 0,01 por parcela.".
- [x] Com Parcelada escolhida, o menu passa a se chamar "Cartão" e só tem os cartões. Se uma conta estava escolhida antes, ela sai.
- [x] Escolha uma categoria e o Cartão Nubank, com a data de hoje. O campo Fatura mostra a fatura calculada e o texto "1ª parcela; as outras vêm depois".
- [x] Salve: aparece "Lançamento "Fone novo" salvo em 3 parcelas." com "Ver". "Ver" leva ao mês da 1ª parcela, onde está "Fone novo (1/3)" com R$ 100,02; nos dois meses seguintes aparecem "(2/3)" e "(3/3)" com R$ 100,00.
- [x] Tudo pelo teclado: nome, Tab, valor, Tab, digite "parc" e Enter na Recorrência, Tab, parcelas, Tab, categoria e Enter, Tab, digite "nub" e Enter no Cartão, Tab (chave Estorno), Tab (data) e Enter salva.
- [x] Na troca para Ganho, a opção "Parcelada" fica desativada.
- [x] Num lançamento novo, comece a digitar "Fone Blue" e escolha a sugestão: a Recorrência vem como "Parcelada" com 3 parcelas, e o Cartão Nubank já escolhido.

## Editar uma parcela

- [x] Em M+1, clique em "Fone Bluetooth (2/3)": a janela mostra "Parcelada · 3x" travado na Recorrência, sem o campo Parcelas, sem a chave Estorno e com o segmento "Ganho" desativado.
- [x] O campo Fatura mostra o mês M+1 (o da parcela 2), e não o da 1ª parcela. Salvar sem mudar nada deixa a parcela onde estava.
- [x] Mude o nome e clique em Salvar: aparece "Alterar "Fone Bluetooth (2/3)"?", com "Só este" (1 parcela), "Este e os próximos" (2 parcelas) e "Todos" (3 parcelas), e o foco em "Só este".
- [x] "Cancelar" volta à janela sem salvar. "Este e os próximos" muda a 2 e a 3; a 1 continua com o nome antigo.
- [x] Troque a fatura da parcela e escolha "Todos": as outras andam junto, mantendo um mês entre cada uma.

## Estorno

- [x] Num lançamento novo, a chave "Estorno" só aparece ao lado do campo quando um cartão está escolhido. Com uma conta, ela some.
- [x] Ligue a chave: o menu passa a se chamar "Cartão" (só cartões) e a Recorrência fica em "Única", travada. Se estava "Parcelada", volta para "Única".
- [x] Com o foco na chave, a barra de espaço e o Enter ligam e desligam, sem salvar. Tab até a Data e Enter salva.
- [x] Com a chave ligada, digite "Padar" no nome e escolha "Padaria" (que foi numa conta): a categoria é preenchida, mas o cartão e a chave continuam como estavam.
- [x] Salve um estorno de R$ 50,00: na lista do mês da fatura ele aparece como "−R$ 50,00" com a etiqueta "estorno", e o total do mês diminui R$ 50,00.
- [x] Clique no estorno do "Restaurante" na lista do mês: abre "Editar lançamento" com a chave Estorno ligada. Desligue e salve: ele vira despesa (sem o sinal de menos).

## Faturas na tela de Cartões

- [x] Em Cartões, escolha o Nubank: a seção "Faturas" lista os meses do mais recente para o mais antigo (M+2, M+1 e M), cada um com a etiqueta, as datas e o total.
- [x] A fatura que recebe as compras de hoje tem a etiqueta "Aberta" e fica em destaque, com o mês e o total em negrito. As seguintes são "Futura".
- [x] Uma fatura que ainda não venceu mostra "Fecha dd/mm · vence dd/mm · sai da conta Nubank". Uma que já venceu tem a etiqueta "Paga" (com o ícone de marcado) e "Paga em 12/<mês> pela conta Nubank, automaticamente".
- [x] A fatura de M do Nubank soma R$ 868,30: as compras (R$ 898,30) menos o estorno do Restaurante (R$ 30,00).
- [x] No Inter, a fatura de M+1 fica em R$ 0,00, com "Crédito de R$ 15,10 para a próxima fatura" (Netflix de R$ 44,90 menos o estorno de R$ 60,00 da Mochila). A de M+2 mostra "Inclui crédito de R$ 15,10 da anterior" e fica em R$ 29,80.
- [x] Entre o dia do fechamento e o do vencimento (no Inter, do dia 8 ao 14), a fatura do mês aparece como "Fechada".
- [x] Lance uma compra num cartão e volte a Cartões: o total da fatura dela já mudou.

## Editar o cartão

- [x] No Nubank, "Editar cartão": troque o fechamento para 20 e o vencimento para 27 e salve. Aparece "N lançamentos mudaram de fatura." (com os exemplos, 2) e surge a fatura do mês passado.
- [x] Na tela do mês, o Combustível e o Restaurante do mês passado saem de M e aparecem no mês passado.
- [x] Um lançamento com a fatura trocada à mão não muda de fatura quando o fechamento muda.
- [x] Mudar só o nome do cartão não mostra a mensagem.
