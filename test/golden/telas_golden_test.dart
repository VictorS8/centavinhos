// Capturas das telas em test/golden/capturas/. Se uma tela mudar, o teste
// falha e mostra a diferença em test/golden/failures/. Quando a mudança for de
// propósito, gere as capturas de novo com:
//   flutter test --update-goldens test/golden

import 'package:centavinhos/data/configuracoes.dart';
import 'package:centavinhos/data/database.dart';
import 'package:centavinhos/data/dev/dados_exemplo.dart';
import 'package:centavinhos/data/providers.dart';
import 'package:centavinhos/ui/app.dart';
import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:centavinhos/ui/lancamento/seletor_categorias.dart';
import 'package:centavinhos/ui/widgets/campo_valor.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'fontes.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
    await carregarFontesDoApp();
  });
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Abre o app com a cor e o modo pedidos, vai até [destino] na barra
  /// lateral (se houver), faz o passo [depois] (se houver), põe o foco do
  /// teclado no botão [foco] (se houver) e compara com a captura [nome].
  /// Com [dadosExemplo], o banco tem os dados de exemplo de 12/10/2026; [antes]
  /// muda o banco antes de abrir o app.
  Future<void> capturar(
    WidgetTester tester,
    String nome, {
    String cor = 'verde',
    String modo = 'claro',
    bool boasVindasConcluida = false,
    bool dadosExemplo = false,
    Future<void> Function()? antes,
    String? destino,
    Future<void> Function(WidgetTester tester)? depois,
    String? foco,
    bool windows = false,
  }) async {
    await tester.runAsync(() async {
      if (dadosExemplo) await gerarDadosExemplo(db, hoje: DateTime(2026, 10, 12));
      // Mudanças no banco só antes de abrir o app: com a tela aberta, as
      // consultas dela seguram o banco no relógio falso do teste.
      await antes?.call();
      await db.definirConfiguracao(ChaveConfiguracao.temaCor, cor);
      await db.definirConfiguracao(ChaveConfiguracao.temaModo, modo);
      if (boasVindasConcluida) {
        await db.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1');
      }
    });
    // Como Windows, os campos de texto não mostram a gota de seleção do
    // celular. A troca precisa ser desfeita antes do fim do teste.
    if (windows) debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bancoProvider.overrideWithValue(db),
          hojeProvider.overrideWithValue(DateTime(2026, 10, 12)),
        ],
        child: const CentavinhosApp(),
      ),
    );
    await tester.runAsync(() => db.observarConfiguracoes().first);
    await tester.pumpAndSettle();
    if (destino != null) {
      await tester.tap(find.text(destino).last);
      await esperarBanco(tester);
    }
    if (depois != null) {
      await depois(tester);
      await esperarBanco(tester);
    }
    if (foco != null) {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
      Focus.of(tester.element(find.text(foco))).requestFocus();
      await tester.pumpAndSettle();
    }

    // Os logos são imagens: precisam ser lidas antes da captura.
    await tester.runAsync(() async {
      for (final elemento in find.byType(Image).evaluate()) {
        await precacheImage((elemento.widget as Image).image, elemento);
      }
    });
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/$nome.png'));
    debugDefaultTargetPlatformOverride = null;

    // Desmonta antes de fechar o banco, para encerrar os fluxos do Drift.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('boas-vindas, verde claro', (tester) async {
    await capturar(tester, 'boas_vindas_verde_claro');
  });

  testWidgets('boas-vindas, verde escuro', (tester) async {
    await capturar(tester, 'boas_vindas_verde_escuro', modo: 'escuro');
  });

  testWidgets('boas-vindas, roxo escuro', (tester) async {
    await capturar(tester, 'boas_vindas_roxo_escuro', cor: 'roxo', modo: 'escuro');
  });

  testWidgets('boas-vindas com foco no "Começar", verde claro', (tester) async {
    await capturar(tester, 'boas_vindas_foco_verde_claro', foco: 'Começar');
  });

  testWidgets('boas-vindas com foco no "Começar", verde escuro', (tester) async {
    await capturar(tester, 'boas_vindas_foco_verde_escuro', modo: 'escuro', foco: 'Começar');
  });

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto).last);
    await tester.pumpAndSettle();
  }

  Future<void> tocarDica(WidgetTester tester, String dica) async {
    await tester.tap(find.byTooltip(dica).first);
    await tester.pumpAndSettle();
  }

  group('tela do mês', () {
    // Como a imagem de referência docs/telas/01-mes-claro.png, sem as partes
    // das etapas 7 a 9 (filtro, saldo e PDF).
    testWidgets('outubro, verde claro', (tester) async {
      await capturar(tester, 'mes_verde_claro', dadosExemplo: true);
    });

    testWidgets('outubro, verde escuro', (tester) async {
      await capturar(tester, 'mes_verde_escuro', modo: 'escuro', dadosExemplo: true);
    });

    testWidgets('outubro, azul claro', (tester) async {
      await capturar(tester, 'mes_azul_claro', cor: 'azul', dadosExemplo: true);
    });

    testWidgets('foco do teclado numa linha, verde claro', (tester) async {
      await capturar(tester, 'mes_foco_linha_verde_claro', dadosExemplo: true, foco: 'Padaria');
    });

    testWidgets('foco do teclado numa linha, verde escuro', (tester) async {
      await capturar(
        tester,
        'mes_foco_linha_verde_escuro',
        modo: 'escuro',
        dadosExemplo: true,
        foco: 'Padaria',
      );
    });

    testWidgets('mês sem lançamentos, verde claro', (tester) async {
      await capturar(tester, 'mes_vazio_verde_claro', boasVindasConcluida: true);
    });

    testWidgets('divisão do "+1 categoria" aberta, verde claro', (tester) async {
      await capturar(
        tester,
        'mes_divisao_verde_claro',
        dadosExemplo: true,
        depois: (tester) => tocar(tester, '+1 categoria'),
      );
    });

    testWidgets('janela de editar, com o "Excluir", verde claro', (tester) async {
      await capturar(
        tester,
        'mes_editar_verde_claro',
        windows: true,
        dadosExemplo: true,
        depois: (tester) async {
          await tocar(tester, 'Mercado Atacadão');
          // A janela pede os dados ao banco ao aparecer.
          await esperarBanco(tester);
          await esperarBanco(tester);
        },
      );
    });

    testWidgets('confirmação de excluir uma parcela, verde claro', (tester) async {
      await capturar(
        tester,
        'mes_excluir_parcela_verde_claro',
        dadosExemplo: true,
        depois: (tester) async {
          Focus.of(tester.element(find.text('Fone Bluetooth (1/3)'))).requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.delete);
          await esperarBanco(tester);
        },
      );
    });
  });

  testWidgets('ajustes, verde claro', (tester) async {
    await capturar(
      tester,
      'ajustes_verde_claro',
      boasVindasConcluida: true,
      destino: 'Ajustes',
    );
  });

  group('cadastros', () {
    testWidgets('contas, verde claro', (tester) async {
      await capturar(tester, 'cadastros_contas_verde_claro', dadosExemplo: true, destino: 'Cadastros');
    });

    testWidgets('contas com as arquivadas, verde claro', (tester) async {
      await capturar(
        tester,
        'cadastros_contas_arquivadas_verde_claro',
        dadosExemplo: true,
        antes: () async {
          await db.contasDao.criar(
            nome: 'Poupança antiga',
            tipo: 'banco',
            saldoInicialCentavos: 125050,
            dataSaldoInicial: DateTime(2026, 9, 1),
          );
          final inter = await (db.select(db.contas)..where((c) => c.nome.equals('Inter')))
              .getSingle();
          final cartaoInter = await (db.select(db.cartoes)
                ..where((c) => c.nome.equals('Inter')))
              .getSingle();
          await db.cartoesDao.arquivar(cartaoInter.id);
          await db.contasDao.arquivar(inter.id);
        },
        destino: 'Cadastros',
        depois: (tester) => tocar(tester, 'Mostrar arquivadas'),
      );
    });

    testWidgets('categorias, verde claro', (tester) async {
      await capturar(
        tester,
        'cadastros_categorias_verde_claro',
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) => tocar(tester, 'Categorias'),
      );
    });

    testWidgets('categorias, verde escuro', (tester) async {
      await capturar(
        tester,
        'cadastros_categorias_verde_escuro',
        modo: 'escuro',
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) => tocar(tester, 'Categorias'),
      );
    });

    testWidgets('categorias de ganho, roxo claro', (tester) async {
      await capturar(
        tester,
        'cadastros_categorias_ganhos_roxo_claro',
        cor: 'roxo',
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) async {
          await tocar(tester, 'Categorias');
          await tocar(tester, 'Ganhos');
        },
      );
    });

    testWidgets('tags, verde claro', (tester) async {
      await capturar(
        tester,
        'cadastros_tags_verde_claro',
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) => tocar(tester, 'Tags'),
      );
    });

    testWidgets('janela de editar conta, verde claro', (tester) async {
      await capturar(
        tester,
        'janela_conta_verde_claro',
        windows: true,
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) => tocarDica(tester, 'Editar'),
      );
    });

    testWidgets('janela de nova conta, verde escuro', (tester) async {
      await capturar(
        tester,
        'janela_nova_conta_verde_escuro',
        windows: true,
        modo: 'escuro',
        dadosExemplo: true,
        destino: 'Cadastros',
        depois: (tester) => tocar(tester, 'Nova conta'),
      );
    });
  });

  group('cartões', () {
    testWidgets('cartões, verde claro', (tester) async {
      await capturar(tester, 'cartoes_verde_claro', dadosExemplo: true, destino: 'Cartões');
    });

    testWidgets('cartões, verde escuro', (tester) async {
      await capturar(
        tester,
        'cartoes_verde_escuro',
        modo: 'escuro',
        dadosExemplo: true,
        destino: 'Cartões',
      );
    });

    testWidgets('cartões sem nenhum cadastrado, verde claro', (tester) async {
      await capturar(tester, 'cartoes_vazio_verde_claro', boasVindasConcluida: true, destino: 'Cartões');
    });

    testWidgets('janela de editar cartão, verde claro', (tester) async {
      await capturar(
        tester,
        'janela_cartao_verde_claro',
        windows: true,
        dadosExemplo: true,
        destino: 'Cartões',
        depois: (tester) => tocar(tester, 'Editar cartão'),
      );
    });
  });

  group('lançamento', () {
    Finder campo(String rotulo) => find.widgetWithText(TextField, rotulo);

    Future<void> novoLancamento(WidgetTester tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      // A janela só pede os dados ao aparecer; a segunda espera deixa o
      // banco responder.
      await esperarBanco(tester);
      await esperarBanco(tester);
    }

    /// Digita número a número, como o valor estilo caixa eletrônico pede.
    Future<void> digitarValor(WidgetTester tester, Finder alvo, String digitos) async {
      await tester.ensureVisible(alvo);
      await tester.tap(alvo);
      await tester.pump();
      final editavel = find.descendant(of: alvo, matching: find.byType(EditableText));
      for (final digito in digitos.split('')) {
        final atual = tester.widget<EditableText>(editavel).controller.text;
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: '$atual$digito',
            selection: TextSelection.collapsed(offset: atual.length + 1),
          ),
        );
        await tester.pump();
      }
    }

    Future<void> escolherNoMenu(WidgetTester tester, String rotulo, String opcao) async {
      await tocar(tester, rotulo);
      await tester.tap(find.widgetWithText(MenuItemButton, opcao).last);
      await tester.pumpAndSettle();
    }

    Future<void> escolherCategoria(WidgetTester tester, String busca) async {
      final alvo = find.descendant(
        of: find.byKey(const ValueKey('busca')),
        matching: find.byType(TextField),
      );
      await tester.enterText(alvo, busca);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    /// Escolhe a sugestão de nome conhecido, que preenche o resto.
    Future<void> escolherNome(WidgetTester tester, String busca, String nome) async {
      // Os nomes usados do tipo escolhido chegam do banco depois da troca.
      await esperarBanco(tester);
      await tester.enterText(campo('Nome'), busca);
      await tester.pumpAndSettle();
      await tester.tap(find.text(nome).last);
      await esperarBanco(tester);
    }

    testWidgets('despesa com uma categoria, verde claro', (tester) async {
      await capturar(
        tester,
        'lancamento_despesa_verde_claro',
        windows: true,
        dadosExemplo: true,
        depois: (tester) async {
          await novoLancamento(tester);
          await tester.enterText(campo('Nome'), 'Padaria do bairro');
          await digitarValor(tester, campo('Valor'), '1850');
          await escolherCategoria(tester, 'lanch');
          await escolherNoMenu(tester, 'Conta ou cartão', 'Carteira');
        },
      );
    });

    // Como a imagem de referência docs/telas/03-novo-lancamento.png.
    for (final modo in ['claro', 'escuro']) {
      testWidgets('despesa no cartão com duas categorias, verde $modo', (tester) async {
        await capturar(
          tester,
          'lancamento_cartao_multicategoria_verde_$modo',
          windows: true,
          modo: modo,
          dadosExemplo: true,
          depois: (tester) async {
            await novoLancamento(tester);
            await escolherNome(tester, 'atac', 'Mercado Atacadão');
            await digitarValor(tester, campo('Valor'), '10000');
            final valores = find.descendant(
              of: find.byType(SeletorCategorias),
              matching: find.byType(CampoValor),
            );
            await digitarValor(tester, valores.at(0), '8000');
            await digitarValor(tester, valores.at(1), '2000');
            await tester.enterText(campo('Data'), '06/10/2026');
            await tester.pumpAndSettle();
            await tester.tap(campo('Nome'));
            await tester.pumpAndSettle();
          },
        );
      });
    }

    testWidgets('ganho, roxo claro', (tester) async {
      await capturar(
        tester,
        'lancamento_ganho_roxo_claro',
        windows: true,
        cor: 'roxo',
        dadosExemplo: true,
        depois: (tester) async {
          await novoLancamento(tester);
          await tester.tap(find.text('Ganho'));
          await esperarBanco(tester);
          await escolherNome(tester, 'sal', 'Salário');
          await digitarValor(tester, campo('Valor'), '400000');
        },
      );
    });

    testWidgets('sugestões de nome abertas, verde claro', (tester) async {
      await capturar(
        tester,
        'lancamento_sugestoes_verde_claro',
        windows: true,
        dadosExemplo: true,
        depois: (tester) async {
          await novoLancamento(tester);
          await tester.enterText(campo('Nome'), 'a');
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('"Mais detalhes" aberto, verde claro', (tester) async {
      await capturar(
        tester,
        'lancamento_mais_detalhes_verde_claro',
        windows: true,
        dadosExemplo: true,
        depois: (tester) async {
          await novoLancamento(tester);
          await escolherNome(tester, 'corrida', 'Corrida de aplicativo');
          await digitarValor(tester, campo('Valor'), '2340');
          await tester.enterText(campo('Observação'), 'Ida ao cliente');
          await tester.pumpAndSettle();
        },
      );
    });
  });
}

/// Deixa o banco responder (ele roda fora do relógio falso dos testes) e
/// redesenha a tela.
Future<void> esperarBanco(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  await tester.pumpAndSettle();
}
