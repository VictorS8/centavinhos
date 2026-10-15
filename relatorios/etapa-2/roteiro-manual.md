# Roteiro manual · Etapa 2

> Abra com `flutter run -d windows`. Para ter dados para testar, vá em Ajustes → "Recriar dados de exemplo" (só no modo de desenvolvimento). Os exemplos têm as contas Carteira, Nubank e Inter, os cartões Nubank e Inter e as tags "trabalho" e "viagem".

## Banco atualizado

- [ ] Se você já tinha usado o app na etapa 1, ele abre normalmente, sem voltar às boas-vindas, e as contas e cartões continuam lá (o banco passou da versão 1 para a 2 sozinho).

## Cadastros → Contas

- [x] Abre com o título "Cadastros", as abas Contas, Categorias e Tags, e a lista de contas: cada uma com ícone, "Banco · saldo inicial em 01/09/2026" (ou Carteira) e o saldo à direita.
- [x] As três contas dos exemplos mostram o ícone de arquivar (caixa), não o de lixeira, porque já foram usadas.
- [x] Em "Nova conta", a janela abre com o cursor em "Nome da conta", "Saldo em" já com a data de hoje e o texto "Dê um nome à conta." no rodapé, com o Salvar travado.
- [x] Escreva "nubank" (minúsculo): aparece "Já existe uma conta com esse nome.".
- [x] Escreva "Reserva", digite 5, 0, 0, 0, 0 e "-" no saldo: mostra −R$ 500,00.
- [x] Em "Saldo em", escreva uma data de amanhã: aparece "A data do saldo não pode ser depois de hoje.". Escreva 31/02: aparece "Data inválida. Use dd/mm ou dd/mm/aaaa.".
- [x] Escreva 1/10 e aperte Tab: o campo vira "01/10/<ano atual>".
- [x] O ícone de calendário abre o calendário em português, sem dias depois de hoje. Escolha um dia: o campo mostra a data escolhida.
- [x] Usando só o Tab, a ordem é: nome, Carteira, Banco, saldo, data, calendário, Cancelar e Salvar.
- [x] Enter em qualquer campo salva. A Reserva aparece na lista com o ícone de lixeira (nunca usada).
- [x] Clique no lápis da Reserva: a janela "Editar conta" vem com tudo preenchido. Troque o saldo e salve: a lista mostra o valor novo.
- [x] Esc fecha a janela sem salvar.
- [x] Lixeira na Reserva: pergunta "Excluir "Reserva"?" dizendo que ela nunca foi usada. Confirme: ela some e aparece a mensagem "Conta "Reserva" excluída." no rodapé.
- [x] Arquivar a Nubank: aparece "Não é possível arquivar "Nubank"" com "Troque antes a conta que paga o cartão Nubank.". "Entendi" fecha e nada muda.

## Cadastros → Categorias

- [x] Abre em Despesas, com as categorias em ordem alfabética, a inicial num círculo, "N subcategorias" ao lado e as subcategorias com um marcador logo abaixo.
- [x] Em Ganhos, aparecem só Outros, Reembolso, Renda extra, Rendimentos e Salário.
- [x] O "+" de Alimentação abre "Nova subcategoria de Alimentação". Escreva "lanches": aparece "Já existe uma subcategoria com esse nome.". Escreva "Padaria" e salve: ela entra na lista e o contador vira "4 subcategorias".
- [x] O lápis de uma categoria abre "Renomear categoria" com o nome atual. Renomeie e veja a lista se reordenar.
- [x] "Nova categoria" em Despesas cria uma categoria de despesa; em Ganhos, de ganho.
- [x] Educação nunca foi usada: a lixeira pergunta "Excluir "Educação"?" e avisa "As 2 subcategorias dela também.". Confirme: Educação, Cursos e Livros somem.
- [x] Casa foi usada (Mercado, Limpeza e Aluguel nos exemplos): o ícone é de arquivar. Confirme: Casa e as subcategorias somem.
- [x] Marque "Mostrar arquivadas" (no fim da lista): Casa volta esmaecida, com "5 subcategorias · arquivada", e cada subcategoria com "arquivada". Só o botão de desarquivar aparece nelas.
- [x] Desarquive a Casa: ela e as cinco subcategorias voltam ao normal.
- [x] Arquive a Casa de novo e desarquive só o Mercado: a Casa volta junto, mas as outras subcategorias continuam arquivadas.

## Cadastros → Tags

- [x] Lista "trabalho" com "usada em 2 lançamentos" (ícone de arquivar) e "viagem" com "sem uso" (ícone de lixeira).
- [x] "Nova tag" com "#Mercado livre": salva como "Mercado livre", sem o #.
- [x] Criar "Viagem" mostra "Já existe uma tag com esse nome.".
- [x] Arquive "trabalho": ela some. Marque "Mostrar arquivadas": volta com "usada em 2 lançamentos · arquivada". Desarquive.
- [x] Depois de arquivar "trabalho", tente criar uma tag "Trabalho": aparece "Já existe uma tag arquivada com esse nome. Desarquive-a em "Mostrar arquivadas".".

## Cartões

- [x] Abre com "Cartões", o botão "Novo cartão", a lista (Inter e Nubank, com "Fecha dia N · vence dia N") e o primeiro cartão escolhido à direita.
- [x] O quadro da direita mostra Fechamento, Vencimento e Conta de pagamento, e a seção "Faturas" com o aviso de que chegam na etapa 5.
- [x] Clicar no Nubank troca o quadro para ele, com o item destacado na lista.
- [x] "Novo cartão": sem nome, aparece "Dê um nome ao cartão."; fechamento 32 mostra "Fechamento e vencimento vão de 1 a 31."; sem conta, "Escolha a conta que paga o cartão.".
- [x] O menu "Pago pela conta" mostra só contas ativas (sem as arquivadas).
- [x] Salve um cartão "C6" (fecha 1, vence 10, pago pela Carteira): ele aparece na lista já escolhido, com o botão "Excluir" (nunca usado).
- [x] "Editar cartão" no C6: troque o vencimento para 20 e aperte Enter: o quadro mostra "Dia 20".
- [x] Exclua o C6: pergunta "Excluir "C6"?" e ele some.
- [x] Os cartões dos exemplos mostram "Arquivar". Arquive o Inter: ele some da lista. "Mostrar arquivados" traz ele esmaecido, com "(arquivado)" no título e o botão "Desarquivar".
- [x] Com o Inter arquivado, arquive a conta Inter em Cadastros. Volte em Cartões e tente desarquivar o Inter: aparece "Desarquive antes a conta Inter, que paga este cartão.".

## Boas-vindas (não mudou)

- [x] Em Ajustes → "Apagar tudo e voltar às boas-vindas", a tela de boas-vindas continua igual à da etapa 1, com Carteira/Banco, fechamento e vencimento funcionando como antes.

## Tema

- [x] Troque o Windows para o modo escuro: as telas de Cadastros e Cartões acompanham, com o texto legível em todas as linhas e janelas.
