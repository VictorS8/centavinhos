# Progresso do Centavinhos

Diário das etapas da "Ordem de construção" do escopo. Atualizado ao fim de cada etapa.

## Etapas

- [x] 1. Base do app (14/10/2026)
- [ ] 2. Cadastros
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
- **Ferramentas de desenvolvimento:** com `kDebugMode`, as boas-vindas têm "Preencher com dados de exemplo" e Ajustes tem "Recriar dados de exemplo" e "Apagar tudo e voltar às boas-vindas".
- **Testes em três níveis e relatório por etapa** (além do escopo, pedido em 14/10/2026):
  - testes rápidos em `test/`;
  - capturas de tela golden em `test/golden/capturas/`;
  - testes de integração no app real em `integration_test/`;
  - o script `tool/relatorio.dart`, que junta tudo em `relatorios/etapa-N/index.html`, com o roteiro manual `relatorios/etapa-N/roteiro-manual.md`.

  Os testes que não estavam no relatório da etapa anterior aparecem como "novo".
  - No relatório, as caixas do roteiro são clicáveis, mas ficam salvas só no navegador (`localStorage`). O `.md` não é alterado pelo relatório: João atualiza o `roteiro-manual.md` à mão, e um item mudado no `.md` depois do clique passa a valer o `.md`. Aceita `[x]`, `[X]` e `[ x ]`.
- **`hojeProvider`** (`lib/ui/hoje_provider.dart`): a data de hoje vem de um provider, trocado por 12/10/2026 nos testes e nas capturas. Todo código novo que precisar de "hoje" deve ler dele, nunca de `DateTime.now()` direto.

## Pendências para etapas seguintes

Coisas que uma etapa deixou prontas pela metade ou que outra etapa precisa lembrar.

- **Etapa 2:** as linhas de conta e cartão da tela de boas-vindas (`lib/ui/telas/tela_boas_vindas.dart`) servem de base para os formulários de Cadastros e Cartões. Vale extrair os campos para widgets próprios.
- **Etapa 3:** o botão + e o Ctrl+N abrem um aviso provisório (`_novoLancamento` em `lib/ui/casca_principal.dart`). O `CampoValor` já está pronto.
- **Etapa 4:** `TelaMes` (`lib/ui/telas/telas_vazias.dart`) ainda é provisória e só mostra o mês atual. O `hojeProvider` guarda a data de quando o app abriu: se o app ficar aberto na virada do dia, ele não muda sozinho. Resolver aqui ou, no máximo, na etapa 7 (saldo de hoje).
- **Etapa 2 em diante:** as boas-vindas rolam a tela quando há várias contas e cartões, e o botão "Começar" pode ficar abaixo da dobra em 1280 × 800. Nos testes de integração, use `tester.ensureVisible` antes de tocar em botões no fim de telas longas.
- **Etapa 5:** o gerador de exemplo (`lib/data/dev/dados_exemplo.dart`) calcula o mês da fatura de forma simplificada, que só funciona com vencimento depois do fechamento. Trocar pela regra de `lib/domain/` quando ela existir. Nos exemplos, a `descricao` das parcelas é guardada sem o "(1/3)", que fica em `parcela_atual`/`total_parcelas`; a etapa 5 confirma esse formato.
- **Etapa 10:** o tema já lê `tema_cor` e `tema_modo` do banco e muda na hora; falta só a tela. A cor de destaque do Windows é lida uma vez ao abrir o app.

## Como rodar

- Relatório da etapa: `dart run tool/relatorio.dart N`. Use `--sem-integracao` para pular o app real (mais rápido) e `--nao-abrir` para não abrir o navegador.
- Só os testes rápidos e as capturas: `flutter test`. Só a integração: `flutter test integration_test -d windows`.
- Atualizar as capturas depois de uma mudança visual de propósito: `flutter test --update-goldens test/golden`. Elas valem para esta máquina e esta versão do Flutter; se o Flutter for atualizado, pode ser preciso gerar de novo.
- Depois de mudar `lib/data/tabelas.drift` ou `lib/data/database.dart`: `dart run build_runner build`. O arquivo gerado `lib/data/database.g.dart` fica no repositório.
- Banco do app: `%APPDATA%\Centavinhos\Centavinhos\centavinhos.sqlite`. Para voltar às boas-vindas, use Ajustes → "Apagar tudo e voltar às boas-vindas" (modo de desenvolvimento) ou apague o arquivo com o app fechado.
