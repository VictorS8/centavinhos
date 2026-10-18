# Roteiro manual · Etapa 4

> Abra com `flutter run -d windows`. Para ter dados para testar, vá em Ajustes → "Recriar dados de exemplo" (só no modo de desenvolvimento). Os exemplos ficam em volta do mês de hoje: as contas Carteira, Nubank e Inter, o cartão Nubank (fecha dia 5, vence dia 12), o cartão Inter (fecha dia 8, vence dia 15), "Mercado Atacadão" com duas categorias, "Fone Bluetooth" em 3 parcelas, Salário, Aluguel e Netflix mensais, um estorno do "Restaurante" e uma transferência do Nubank para o Inter. Os valores abaixo são os do mês atual nos exemplos.
>
> O seletor de filtro, a linha de Saldo e o "Gerar PDF" da imagem de referência chegam nas etapas 8, 7 e 9.

## Tela do mês

- [x] O app abre na tela do mês, com "‹ <mês atual> <ano> ›" no topo, a seção "Gastos" com o cartão "Total do mês, sem filtro" e a seção "Lançamentos".
- [x] O total do mês atual é R$ 2.242,70: as despesas do mês (em conta e na fatura do mês) menos o estorno de R$ 30,00. Ganhos e a transferência não entram.
- [x] A lista vem da data mais recente para a mais antiga. Compras no cartão do mês passado aparecem aqui, porque contam no mês da fatura (ex.: "Mercado Atacadão", de dia 28 do mês passado).
- [x] Cada linha tem a letra da categoria no círculo, o nome, a categoria e a conta ou o cartão embaixo ("Casa, Mercado · Nubank, vence 12/<mês>"), e o valor e a data à direita.
- [x] O Salário aparece como "+R$ 4.000,00" na cor principal. O estorno do Restaurante aparece como "−R$ 30,00" com a etiqueta "estorno". Aluguel, Salário e Netflix têm a etiqueta "mensal".
- [x] A transferência aparece como "Transferência Nubank para Inter", com o ícone de setas e "Nubank → Inter" embaixo, em cor neutra.
- [x] A parcela aparece com o número: "Fone Bluetooth (1/3)".

## Trocar de mês

- [x] A seta da direita vai para o mês seguinte: aparece "Fone Bluetooth (2/3)" e o total muda para R$ 1.344,90.
- [x] A seta da esquerda volta. Duas vezes para trás vai para o mês retrasado.
- [x] Role a lista até o fim e troque de mês: a lista volta para o topo, com o total à vista.
- [x] Vá para Cadastros e volte para Mês: o mês que estava aberto continua o mesmo.
- [x] Num mês sem nada (por exemplo, um ano para a frente), aparece "Nenhum lançamento em <mês>. Aperte + ou Ctrl+N para lançar." e o total fica em R$ 0,00.

## Divisão entre categorias

- [x] Em "Mercado Atacadão", clique na etiqueta "+1 categoria": abre uma caixa "Divisão" com "Casa, Mercado R$ 300,00", "Casa, Limpeza R$ 112,30" e "Total R$ 412,30".
- [x] Clicar na etiqueta não abre a edição. Um clique fora (ou Esc) fecha a caixa. -> Clicar fora fecha caixa, porem tocand no Esc não fecha (Talvez limitação do componente?) FIXED

## Editar

- [x] Um clique na "Padaria" abre "Editar lançamento" já preenchida, com o botão vermelho "Excluir" à esquerda.
- [x] Mude o valor para R$ 185,00 e salve: a linha e o total mudam na hora (o total sobe R$ 166,50) e aparece "Lançamento "Padaria" salvo." no rodapé, sem "Ver".
- [x] Com o Tab, chegue numa linha da lista (ela fica destacada). Enter abre a edição. -> Não consigo ver destaque em cada linha ao estar usando o tab FIXED
- [x] Edite a "Padaria" e troque a data para um dia do mês seguinte: ela some da lista e a mensagem tem o botão "Ver". "Ver" vai para o mês seguinte, onde ela aparece.
- [x] Na tela de Cadastros, aperte Ctrl+N e salve um lançamento: a mensagem tem "Ver", que volta para a tela do mês dele.
- [x] Um clique no estorno mostra "Editar estornos chega na etapa 5.". Um clique na transferência mostra "Editar transferências chega na etapa 7.". Nenhum dos dois abre a janela.

## Excluir e desfazer

- [x] Com o Tab numa linha, aperte Delete: aparece "Excluir "Padaria"?" com "Cancelar" e "Excluir". "Cancelar" não muda nada.
- [x] Delete de novo e Enter (o "Excluir" já vem com o foco): a linha some, o total cai e aparece "Lançamento "Padaria" excluído." com "Desfazer".
- [x] "Desfazer" traz a Padaria de volta, igual a antes (com a mesma categoria e a mesma conta).
- [x] Sem clicar, a mensagem com "Desfazer" some sozinha depois de uns 6 segundos.
- [x] No mês seguinte, clique em "Fone Bluetooth (2/3)" e em "Excluir": a pergunta diz "Esta compra foi parcelada em 3 vezes." e mostra "Só este (1 parcela)", "Este e os próximos (2 parcelas)" e "Todos (3 parcelas)".
- [x] "Este e os próximos" fecha as duas janelas, tira a parcela 2 (e a 3, no mês depois) e mostra "2 lançamentos "Fone Bluetooth" excluídos.". "Desfazer" traz as duas de volta.
- [x] Delete no "Aluguel": a pergunta diz que ele se repete todo mês e mostra "1 mês", "2 meses" e "3 meses". "Todos" tira o Aluguel de todos os meses.
- [x] Delete na transferência: confirma com "Excluir" e aparece "Transferência excluída.". O total de gastos não muda.

## Virada do dia

- [ ] (Opcional, só se o app ficar aberto na virada.) Deixe o app aberto no mês atual de um dia para o outro, na virada do mês: depois da meia-noite, a tela passa sozinha para o mês novo. -> Inviavel testar agora, não vou fazer
