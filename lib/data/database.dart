import 'package:drift/drift.dart';

import '../domain/datas.dart';
import 'categorias_padrao.dart';
import 'configuracoes.dart';
import 'daos/cartoes_dao.dart';
import 'daos/categorias_dao.dart';
import 'daos/contas_dao.dart';
import 'daos/lancamentos_dao.dart';
import 'daos/tags_dao.dart';

part 'database.g.dart';

/// Uma conta digitada na tela de boas-vindas.
class NovaConta {
  const NovaConta({
    required this.nome,
    required this.tipo,
    required this.saldoInicialCentavos,
  });

  final String nome;

  /// 'carteira' ou 'banco'.
  final String tipo;
  final int saldoInicialCentavos;
}

/// Um cartão digitado na tela de boas-vindas. A conta de pagamento é a
/// posição dela na lista de [NovaConta] salva junto.
class NovoCartao {
  const NovoCartao({
    required this.nome,
    required this.diaFechamento,
    required this.diaVencimento,
    required this.indiceContaPagamento,
  });

  final String nome;
  final int diaFechamento;
  final int diaVencimento;
  final int indiceContaPagamento;
}

@DriftDatabase(include: {'tabelas.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  late final contasDao = ContasDao(this);
  late final cartoesDao = CartoesDao(this);
  late final categoriasDao = CategoriasDao(this);
  late final tagsDao = TagsDao(this);
  late final lancamentosDao = LancamentosDao(this);

  /// 1: as doze tabelas do escopo (etapa 1).
  /// 2: coluna `arquivada` em tags (etapa 2).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _criarDadosIniciais();
    },
    onUpgrade: (m, de, para) async {
      // Cada nova versão do banco ganha aqui o seu passo de migração.
      if (de < 2) await m.addColumn(tags, tags.arquivada);
    },
    beforeOpen: (detalhes) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Categorias padrão e configurações iniciais.
  Future<void> _criarDadosIniciais() async {
    for (final categoria in categoriasPadrao) {
      final paiId = await into(categorias).insert(
        CategoriasCompanion.insert(nome: categoria.nome, tipo: categoria.tipo),
      );
      for (final sub in categoria.subcategorias) {
        await into(categorias).insert(
          CategoriasCompanion.insert(
            nome: sub,
            tipo: categoria.tipo,
            categoriaPaiId: Value(paiId),
          ),
        );
      }
    }
    for (final MapEntry(:key, :value) in configuracoesPadrao.entries) {
      await definirConfiguracao(key, value);
    }
  }

  // Configurações
  //
  // No SQLite, uma chave primária TEXT sem NOT NULL aceita nulo, então o
  // Drift gera `chave` como String?. O SQL segue igual ao escopo e as linhas
  // sem chave (que o app nunca grava) são ignoradas aqui.

  Stream<Map<String, String>> observarConfiguracoes() =>
      select(configuracoes).watch().map(
        (linhas) => {
          for (final linha in linhas) ?linha.chave: linha.valor,
        },
      );

  Future<void> definirConfiguracao(String chave, String valor) =>
      into(configuracoes).insertOnConflictUpdate(
        ConfiguracoesCompanion.insert(chave: Value(chave), valor: valor),
      );

  // Boas-vindas

  /// Grava as contas e os cartões da primeira abertura e marca as boas-vindas
  /// como concluídas, tudo de uma vez. O saldo inicial vale a partir de [hoje].
  Future<void> concluirBoasVindas({
    required List<NovaConta> contas,
    List<NovoCartao> cartoes = const [],
    required DateTime hoje,
  }) {
    if (contas.isEmpty) {
      throw ArgumentError.value(contas, 'contas', 'precisa de ao menos uma');
    }
    return transaction(() async {
      final idsContas = <int>[];
      for (final conta in contas) {
        idsContas.add(
          await into(this.contas).insert(
            ContasCompanion.insert(
              nome: conta.nome,
              tipo: conta.tipo,
              saldoInicialCentavos: Value(conta.saldoInicialCentavos),
              dataSaldoInicial: dataIso(hoje),
            ),
          ),
        );
      }
      for (final cartao in cartoes) {
        await into(this.cartoes).insert(
          CartoesCompanion.insert(
            nome: cartao.nome,
            diaFechamento: cartao.diaFechamento,
            diaVencimento: cartao.diaVencimento,
            contaPagamentoId: idsContas[cartao.indiceContaPagamento],
          ),
        );
      }
      await definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1');
    });
  }

  /// Apaga todos os dados e volta o banco ao estado de recém-criado, com as
  /// categorias padrão e as boas-vindas pendentes. Uso no desenvolvimento.
  Future<void> apagarTudo() => transaction(() async {
    // Filhos antes dos pais, por causa das chaves estrangeiras.
    await delete(lancamentoTags).go();
    await delete(lancamentoCategorias).go();
    await delete(lancamentos).go();
    await delete(transferencias).go();
    await delete(faturas).go();
    await delete(cartoes).go();
    await delete(recorrencias).go();
    await delete(tags).go();
    await (delete(categorias)..where((c) => c.categoriaPaiId.isNotNull())).go();
    await delete(categorias).go();
    await delete(contas).go();
    await delete(filtros).go();
    await delete(configuracoes).go();
    await _criarDadosIniciais();
  });
}
