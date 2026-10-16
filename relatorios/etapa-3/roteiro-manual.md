# Roteiro manual · Etapa 3

> Abra com `flutter run -d windows`. Para ter dados para testar, vá em Ajustes → "Recriar dados de exemplo" (só no modo de desenvolvimento). Os exemplos têm as contas Carteira, Nubank e Inter, o cartão Nubank (fecha dia 5, vence dia 12), o cartão Inter (fecha dia 8, vence dia 15) e lançamentos como "Mercado Atacadão" (Casa, Mercado + Casa, Limpeza, no cartão Nubank) e "Corrida de aplicativo" (na conta Nubank, com a tag "trabalho"). Os exemplos são criados de novo com a regra nova da fatura.
>
> Ainda não há lista de lançamentos (ela chega na etapa 4). Para conferir o que foi salvo, use a mensagem no rodapé, a sugestão do nome repetido e o "usada em N lançamentos" da aba Tags em Cadastros.

## Abrir e fechar

- [x] Ctrl+N abre a janela "Novo lançamento" com o cursor em "Nome". O botão + da barra lateral abre a mesma janela.
- [x] Despesa vem marcada. "Transferência" aparece apagada e, com o mouse em cima, mostra "Chega na etapa 7".
- [x] Valor mostra R$ 0,00, Recorrência mostra "Única" e Data mostra a data de hoje.
- [x] Com a janela aberta, Ctrl+N não abre outra.
- [x] Esc fecha a janela sem salvar, com o cursor em qualquer campo, inclusive em "Conta ou cartão" com o menu fechado.
- [x] O X do canto e o "Cancelar" também fecham sem salvar.

## Lançamento só pelo teclado

- [x] Escreva "Pão de queijo", aperte Tab e digite 1, 2, 5 e 0: o valor mostra R$ 0,01, R$ 0,12, R$ 1,25 e R$ 12,50.
- [x] Tab vai para Recorrência e outro Tab para Categoria (sem parar na setinha do menu).
- [x] Em Categoria, escreva "lanch": aparece "Alimentação, Lanches". Enter escolhe: ela vira uma etiqueta verde e o campo passa a se chamar "Adicionar categoria", vazio e com o cursor.
- [x] Tab vai para "Conta ou cartão". Escreva "cart": o menu abre com "Carteira" marcada. Enter escolhe e o cursor continua no campo.
- [x] Tab vai para Data (sem parar no ícone do calendário). Enter salva: a janela fecha e aparece "Lançamento "Pão de queijo" salvo." no rodapé.
- [x] Abra de novo e escreva "pão": a sugestão "Pão de queijo" aparece (ele foi salvo).

## Travas do Salvar

- [x] Com a janela vazia, o Salvar fica apagado e o texto acima dos botões diz "Dê um nome ao lançamento.".
- [x] Preenchendo campo a campo, o texto muda para "Digite o valor.", "Escolha uma categoria.", "Escolha a conta ou o cartão." e some quando tudo está certo.
- [x] Em Data, escreva 31/02: aparece "Data inválida. Use dd/mm ou dd/mm/aaaa.". Escreva 3/10 e aperte Tab: vira "03/10/<ano atual>".
- [x] Enter com o Salvar travado não fecha a janela e o cursor continua no mesmo campo.
- [x] Datas no futuro são aceitas (por exemplo, 30/12).

## Nome conhecido

- [x] Escreva "atac": aparece "Mercado Atacadão" numa lista embaixo do nome. Enter (ou clique) escolhe.
- [x] O app preenche "Casa, Mercado" e "Casa, Limpeza", "Cartão Nubank" e a Fatura. O valor continua R$ 0,00 e os dois campos de valor das categorias ficam vazios.
- [x] Clique em outro campo e volte ao Nome: a lista não reabre. Um Esc com o cursor no Nome fecha a janela de primeira.
- [x] Escreva "corrida" e escolha "Corrida de aplicativo": vêm "Transporte, Aplicativos de corrida", a conta Nubank e a tag "trabalho", e "Mais detalhes" abre sozinho.
- [x] Na Despesa, "sal" não sugere "Salário". Em Ganho, sugere, e escolher preenche a categoria Salário e a conta Nubank.
- [x] Esc com a lista de sugestões aberta fecha só a lista. O segundo Esc fecha a janela.

## Multicategoria

- [x] Com valor R$ 100,00, escolha "Casa, Mercado" e depois "Casa, Limpeza": aparece um campo de valor ao lado de cada uma, os dois vazios, e o cursor vai para o primeiro.
- [x] Digite 80,00 no primeiro: o contador embaixo diz "Distribuído R$ 80,00 de R$ 100,00, faltam R$ 20,00", e o Salvar fica travado com "Distribua o valor entre as categorias.".
- [x] Tab vai para o segundo valor. Digite 30,00: o contador diz "sobram R$ 10,00". Corrija para 20,00: o contador fica verde, "Distribuído R$ 100,00 de R$ 100,00", e o Salvar libera.
- [x] Adicione uma terceira categoria: o cursor vai para o valor dela.
- [x] O X de uma etiqueta tira a categoria. Com uma só, o campo de valor dela some.
- [x] Ao escrever "casa" na busca, aparecem "Casa" e todas as subcategorias. Dá para escolher "Casa" sozinha.
- [x] Categorias de ganho não aparecem numa despesa, e vice-versa. Trocar entre Despesa e Ganho tira as categorias escolhidas.

## Conta ou cartão e fatura

- [x] Na Despesa, o menu tem as contas (Carteira, Inter, Nubank) e os cartões ("Cartão Inter", "Cartão Nubank"). No Ganho, o campo se chama "Conta" e só tem as contas.
- [x] Escolha "Cartão Nubank" com a data 12/10: aparece Fatura "Novembro/2026" com "Calculada pela data; pode trocar".
- [x] Mude a data para 03/10: a fatura vira "Outubro/2026". Para 05/10 (dia do fechamento): "Novembro/2026".
- [x] Troque a fatura à mão para "Dezembro/2026": o texto vira "Trocada à mão; não muda com a data". Mude a data: a fatura continua em dezembro.
- [x] Escolha de novo o mês calculado: o texto volta a "Calculada pela data; pode trocar" e a fatura volta a seguir a data.
- [x] Com um cartão escolhido, trocar para Ganho tira o cartão e a Fatura some.
- [x] Contas, cartões e categorias arquivados em Cadastros não aparecem nos menus nem na busca.

## Mais detalhes: tags e observação

- [x] "Mais detalhes: tags e observação" abre os campos Tags e Observação.
- [x] Em Tags, escreva "trab": aparece "trabalho". Enter adiciona a etiqueta.
- [x] Escreva "#aeroporto" e Enter: entra a etiqueta "aeroporto", sem o "#".
- [x] Com o campo de tags vazio, Enter salva o lançamento. Em Cadastros → Tags, "aeroporto" aparece como "usada em 1 lançamento".
- [x] Arquive a tag "viagem" em Cadastros. Num lançamento novo, escreva "viagem" em Tags, Enter e salve: a tag volta a ficar ativa em Cadastros, sem criar outra.
