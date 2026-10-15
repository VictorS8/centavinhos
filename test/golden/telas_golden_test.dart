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
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('tela do mês, verde claro', (tester) async {
    await capturar(tester, 'mes_verde_claro', boasVindasConcluida: true);
  });

  testWidgets('ajustes, verde claro', (tester) async {
    await capturar(
      tester,
      'ajustes_verde_claro',
      boasVindasConcluida: true,
      destino: 'Ajustes',
    );
  });

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto).last);
    await tester.pumpAndSettle();
  }

  Future<void> tocarDica(WidgetTester tester, String dica) async {
    await tester.tap(find.byTooltip(dica).first);
    await tester.pumpAndSettle();
  }

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
}

/// Deixa o banco responder (ele roda fora do relógio falso dos testes) e
/// redesenha a tela.
Future<void> esperarBanco(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  await tester.pumpAndSettle();
}
