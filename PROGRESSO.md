# Progresso do Centavinhos

Diário das etapas da "Ordem de construção" do escopo. Atualizado ao fim de cada etapa.

## Etapas

- [x] 1. Base do app (14/10/2026)
- [x] 2. Cadastros (15/10/2026)
- [ ] 3. Lançamento rápido
- [ ] 4. Tela do mês
- [ ] 5. Cartão
- [ ] 6. Recorrência mensal e total do próximo mês
- [ ] 7. Saldo, transferências, ajuste de fatura e aviso de saldo negativo
- [ ] 8. Filtros salvos e totais da tela do mês
- [ ] 9. Relatório em PDF
- [ ] 10. Configurações
- [ ] 11. Pacote MSIX e Microsoft Store

## Diferenças em relação ao escopo

Tudo que foi feito diferente do escopo, decidido além dele ou deixado para depois. Cada item diz a etapa, o que mudou e por quê.

### Etapa 1

- **Identificador sem domínio:** `CompanyName` = "Centavinhos" no `windows/runner/Runner.rc`, no lugar de `br.com.centavinhosfinancas`. O `path_provider` monta a pasta do banco como `%APPDATA%\<CompanyName>\<ProductName>`; assim ela fica fixa em `%APPDATA%\Centavinhos\Centavinhos\centavinhos.sqlite` (conferido no app rodando) e não depende do domínio, que pode mudar ou nem ser comprado. **Nunca trocar `CompanyName` nem `ProductName` depois que houver dados reais**: o app passaria a abrir um banco vazio. O `--org` só voltaria a importar numa versão Android ou iOS. `LegalCopyright` = "Copyright (C) 2026 João Victor das Neves Sousa Almeida".
- **`sqlite3` no lugar de `sqlite3_flutter_libs`:** o `sqlite3_flutter_libs` foi descontinuado; o pub.dev manda usar o `sqlite3` 3.x, que já embute o SQLite.
- **Sem `flutter_localizations`:** o `material_ui` traz o próprio `GlobalMaterialLocalizations` (com pt-BR), e o do `flutter_localizations` entraria em conflito de nomes. O app usa `GlobalMaterialLocalizations.delegates` do `material_ui`.
- **Menu "Ajustes":** a tela de Configurações aparece como "Ajustes" na barra lateral, como na imagem `docs/telas/01-mes-claro.png`.
- **Valor estilo caixa eletrônico adiantado:** a regra pura (`lib/domain/valor_caixa_eletronico.dart`) e o widget `CampoValor` (`lib/ui/widgets/campo_valor.dart`) já existem, porque as boas-vindas pedem o saldo inicial. A etapa 3 só reaproveita.
- **Saldo inicial negativo:** só no campo de saldo inicial (`CampoValor(permiteNegativo: true)`), a tecla "-" troca o sinal ("−R$ 200,00"), com o texto de apoio "Aperte - para negativo". Os campos de lançamento continuam sem sinal, porque ali o sinal vem do tipo.
- **Texto colado no campo de valor:** vírgula ou ponto seguidos de 1 ou 2 números no fim marcam os centavos ("12,50", "12,5"); sem eles, o texto é lido como reais ("300" → R$ 300,00; "1.234" → R$ 1.234,00). Digitar continua entrando pela direita. Valor máximo: R$ 999.999.999,99 (11 números).
- **Tudo selecionado no campo de valor:** digitar um número com o texto todo selecionado (como acontece ao entrar no campo com Tab) recomeça do zero.
- **Cartões nas boas-vindas:** entram já na etapa 1 (opcionais), com nome, fechamento, vencimento (1 a 31) e conta de pagamento escolhida entre as contas da própria tela.
- **Boas-vindas:** começa com uma conta "Carteira" preenchida (editável e removível). Não deixa duas contas com o mesmo nome. A data do saldo inicial é sempre o dia de hoje.
- **`configuracoes.chave`:** o SQL é igual ao escopo (`chave TEXT PRIMARY KEY`), mas no SQLite isso aceita nulo, então o Drift gera `String?`. O código trata isso; não há mudança no banco.
- **Cores do tema:** nas três cores fixas, a família terciária (`tertiary`/`onTertiary`) é gerada a partir do container terciário da tabela, e o aviso usa os valores da tabela direto (já são o tom harmonizado). O `harmonizeWith` só roda na cor do sistema. Sem cor de destaque do Windows, a cor do sistema cai no verde.
- **Anel de foco nos botões** (pedido em 14/10/2026, depois do fechamento): o foco pelo Tab do Material 3 só clareia 10% do botão e quase não aparecia no "Começar". O tema (`lib/ui/theme/app_theme.dart`) põe um contorno de 3 px de `onSurface` por fora do botão com foco, como o indicador de foco do Material 3, em todos os botões: preenchido e tonal, elevado, de texto, de contorno, de ícone e o +. Fica de fora o `SegmentedButton` (Carteira ou Banco): ele troca o tema dos segmentos por um próprio e a borda dele é a do grupo inteiro, então o foco nele continua só no leve clareado.
- **Ferramentas de desenvolvimento:** com `kDebugMode`, as boas-vindas têm "Preencher com dados de exemplo" e Ajustes tem "Recriar dados de exemplo" e "Apagar tudo e voltar às boas-vindas".
- **Testes em três níveis e relatório por etapa** (além do escopo, pedido em 14/10/2026):
  - testes rápidos em `test/`;
  - capturas de tela golden em `test/golden/capturas/`;
  - testes de integração no app real em `integration_test/`;
  - o script `tool/relatorio.dart`, que junta tudo em `relatorios/etapa-N/index.html`, com o roteiro manual `relatorios/etapa-N/roteiro-manual.md`.

  Os testes que não estavam no relatório da etapa anterior aparecem como "novo".
  - No relatório, as caixas do roteiro são clicáveis, mas ficam salvas só no navegador (`localStorage`). O `.md` não é alterado pelo relatório: João atualiza o `roteiro-manual.md` à mão, e um item mudado no `.md` depois do clique passa a valer o `.md`. Aceita `[x]`, `[X]` e `[ x ]`.
- **`hojeProvider`** (`lib/ui/hoje_provider.dart`): a data de hoje vem de um provider, trocado por 12/10/2026 nos testes e nas capturas. Todo código novo que precisar de "hoje" deve ler dele, nunca de `DateTime.now()` direto.

### Etapa 2

- **Tags com `arquivada` (banco na versão 2):** a tabela `tags` ganhou `arquivada INTEGER NOT NULL DEFAULT 0`, para seguir a mesma regra das contas, cartões e categorias. `schemaVersion = 2`, com `addColumn` no `onUpgrade`; o banco da etapa 1 é migrado sozinho ao abrir. Texto sugerido para o escopo (`docs/`, João altera):
  - tabela `tags` no "Modelo de dados": acrescentar a linha `arquivada INTEGER NOT NULL DEFAULT 0`;
  - seção "Telas": "Nenhum cadastro usado é apagado de vez: contas, cartões, categorias e tags usados em lançamentos são arquivados, para não quebrar relatórios antigos. Os que nunca foram usados podem ser excluídos."
- **Excluir ou arquivar:** item nunca usado é excluído de vez, com confirmação; item usado só é arquivado. O ícone da linha mostra qual dos dois vai acontecer (lixeira ou caixa). "Usado" é:
  - conta: lançamento, transferência, cartão (mesmo arquivado) ou ajuste de fatura;
  - cartão: lançamento ou ajuste de fatura;
  - categoria: lançamento nela ou em alguma subcategoria dela;
  - tag: lançamento.
- **Bloqueios:** não dá para arquivar nem excluir a última conta ativa, nem a conta que paga um cartão ativo ("Troque antes a conta que paga o cartão Nubank."). Não dá para desarquivar um cartão cuja conta de pagamento está arquivada ("Desarquive antes a conta Inter, que paga este cartão."). As regras ficam em `lib/domain/cadastros.dart` e os acessores do banco (`lib/data/daos/`) conferem de novo e lançam `CadastroBloqueado`.
- **Categorias:** arquivar a principal leva as subcategorias; desarquivar a principal traz todas de volta; desarquivar uma subcategoria com a principal arquivada traz a principal (mas não as irmãs). Excluir a principal apaga as subcategorias junto, e só é possível se nenhuma delas foi usada. A subcategoria herda o tipo da principal, tem um nível só, e o tipo não muda depois de criado (só o nome). O contador "N subcategorias" conta as que aparecem logo abaixo (com "Mostrar arquivadas", inclui as arquivadas).
- **Data do saldo inicial editável:** contas novas e editadas em Cadastros têm o campo "Saldo em" (hoje como padrão), que aceita dd/mm, dd/mm/aaaa ou o calendário, não aceita data no futuro e tem o texto "Lançamentos antes desta data não mudam o saldo.". As boas-vindas continuam com a data fixa em hoje. A leitura da data é a regra pura `lib/domain/data_digitada.dart` com o widget `CampoData` (`lib/ui/widgets/campo_data.dart`), prontos para o campo de data do lançamento na etapa 3. Ao sair do campo, uma data válida é reescrita como dd/mm/aaaa.
- **Nomes:** nome repetido fica bloqueado ao criar e ao renomear, comparando sem maiúsculas e sem acentos ("Saude" = "Saúde") e incluindo os arquivados; se o repetido estiver arquivado, a mensagem sugere desarquivar. Os grupos comparados: contas entre si, cartões entre si, categorias principais do mesmo tipo, subcategorias da mesma principal e todas as tags. Espaços nas pontas e repetidos saem do nome; nas tags, o "#" do começo também sai.
- **Tela de Cartões:** segue a imagem `docs/telas/05-cartoes.png`, com "Excluir" ou "Arquivar" ao lado de "Editar cartão" e "Mostrar arquivados" abaixo da lista. A seção "Faturas" tem só o aviso de que chega na etapa 5.
- **Aba Contas e aba Tags** não têm imagem de referência: seguem o desenho da aba Categorias (lista com contorno, ícone redondo, detalhe ao lado do nome, ações à direita). A conta mostra o saldo inicial à direita em Libron; a tag mostra em quantos lançamentos é usada.
- **Mensagens no rodapé:** excluir, arquivar e desarquivar mostram uma mensagem curta ("Conta "Reserva" excluída."), sem "Desfazer". O "Desfazer" do escopo fica só para os lançamentos.
- **Texto do topo de Cadastros:** "Itens nunca usados podem ser excluídos. Os usados em lançamentos são arquivados, para não quebrar relatórios antigos." (a imagem dizia só a segunda parte).
- **Widgets extraídos das boas-vindas:** `CampoDia` e `SeletorTipoConta` em `lib/ui/widgets/`; as capturas das boas-vindas continuam idênticas. `CampoValor` ganhou `onSubmitted` (Enter salva).
- **Relatório roda um arquivo de integração por vez:** no Windows, `flutter test integration_test -d windows` com vários arquivos não consegue abrir o app do segundo em diante ("The log reader stopped unexpectedly"). O `tool/relatorio.dart` agora chama cada `integration_test/*_test.dart` separado.
- **Testes de tela com o banco:** nos testes de `test/`, mudanças no banco com a tela aberta, dentro de `runAsync`, travam (as consultas da tela seguram o banco no relógio falso do teste). Prepare o banco antes de abrir o app (parâmetro `antes` das capturas) e sempre desmonte o app no fim, mesmo quando o teste falha (`testarTela` em `test/ui/cadastros_test.dart`).

## Pendências para etapas seguintes

Coisas que uma etapa deixou prontas pela metade ou que outra etapa precisa lembrar.

- **Etapa 3:** o botão + e o Ctrl+N abrem um aviso provisório (`_novoLancamento` em `lib/ui/casca_principal.dart`). O `CampoValor` e o `CampoData` já estão prontos. Os seletores de conta, cartão, categoria e tag do formulário devem mostrar só os itens não arquivados (os providers `contasProvider`, `cartoesProvider`, `categoriasProvider` e `tagsProvider` trazem todos, com a marca de arquivado). Criar tag pelo formulário deve passar pelo `TagsDao.criar`, que tira o "#".
- **Etapa 3:** decidir se uma categoria principal que tem subcategorias pode ser escolhida direto num lançamento ou só as subcategorias.
- **Etapa 4:** `TelaMes` (`lib/ui/telas/telas_vazias.dart`) ainda é provisória e só mostra o mês atual. O `hojeProvider` guarda a data de quando o app abriu: se o app ficar aberto na virada do dia, ele não muda sozinho. Resolver aqui ou, no máximo, na etapa 7 (saldo de hoje).
- **Etapa 2 em diante:** as boas-vindas rolam a tela quando há várias contas e cartões, e o botão "Começar" pode ficar abaixo da dobra em 1280 × 800. Nos testes de integração, use `tester.ensureVisible` antes de tocar em botões no fim de telas longas.
- **Etapa 5:** mudar o fechamento ou o vencimento de um cartão em "Editar cartão" deve recalcular o `mes_fatura` (e o `mes_referencia`) dos lançamentos desse cartão que não têm `fatura_manual = 1`. Hoje a edição só grava o cartão, porque ainda não há lançamentos no cartão fora dos exemplos. A seção "Faturas" da tela de Cartões (`lib/ui/telas/cartoes/tela_cartoes.dart`) é um aviso provisório.
- **Etapa 5:** o gerador de exemplo (`lib/data/dev/dados_exemplo.dart`) calcula o mês da fatura de forma simplificada, que só funciona com vencimento depois do fechamento. Trocar pela regra de `lib/domain/` quando ela existir. Nos exemplos, a `descricao` das parcelas é guardada sem o "(1/3)", que fica em `parcela_atual`/`total_parcelas`; a etapa 5 confirma esse formato.
- **Etapa 7:** mudar o saldo inicial ou a data dele numa conta muda todo o saldo calculado dela; o cálculo deve sempre ler esses campos na hora, nunca guardar saldo.
- **Etapa 8:** o "está em uso?" dos cadastros (`emUso` em `lib/data/daos/`) não olha os filtros salvos. Quando os filtros existirem, uma conta, um cartão, uma categoria ou uma tag usados num filtro também devem contar como usados, para não serem excluídos e deixarem o filtro com um critério que não existe.
- **Etapa 10:** o tema já lê `tema_cor` e `tema_modo` do banco e muda na hora; falta só a tela. A cor de destaque do Windows é lida uma vez ao abrir o app.

## Como rodar

- Relatório da etapa: `dart run tool/relatorio.dart N`. Use `--sem-integracao` para pular o app real (mais rápido) e `--nao-abrir` para não abrir o navegador.
- Só os testes rápidos e as capturas: `flutter test`. Só a integração, um arquivo por vez (com vários de uma vez, o Windows não abre o app do segundo em diante): `flutter test integration_test/cadastros_test.dart -d windows`. Durante a integração, não mexa no computador: se a janela do app perder o foco, os testes que usam Tab podem falhar.
- Atualizar as capturas depois de uma mudança visual de propósito: `flutter test --update-goldens test/golden`. Elas valem para esta máquina e esta versão do Flutter; se o Flutter for atualizado, pode ser preciso gerar de novo.
- Depois de mudar `lib/data/tabelas.drift` ou `lib/data/database.dart`: `dart run build_runner build`. O arquivo gerado `lib/data/database.g.dart` fica no repositório.
- Banco do app: `%APPDATA%\Centavinhos\Centavinhos\centavinhos.sqlite`. Para voltar às boas-vindas, use Ajustes → "Apagar tudo e voltar às boas-vindas" (modo de desenvolvimento) ou apague o arquivo com o app fechado.
