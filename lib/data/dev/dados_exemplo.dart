import 'package:drift/drift.dart';

import '../../domain/datas.dart';
import '../../domain/fatura.dart';
import '../configuracoes.dart';
import '../database.dart';

/// Apaga tudo e cria um cenário parecido com o das telas de referência:
/// três contas, dois cartões e lançamentos do mês anterior ao seguinte, com
/// multicategoria, parcelas, recorrências, estorno, tags e uma transferência.
///
/// Só deve ser chamado no modo de desenvolvimento (`kDebugMode`).
Future<void> gerarDadosExemplo(AppDatabase db, {DateTime? hoje}) async {
  final agora = hoje ?? DateTime.now();
  await db.apagarTudo();
  await db.transaction(() => _Gerador(db, agora).gerar());
}

class _CartaoExemplo {
  const _CartaoExemplo(this.id, this.diaFechamento, this.diaVencimento);
  final int id;
  final int diaFechamento;
  final int diaVencimento;
}

class _Gerador {
  _Gerador(this.db, DateTime agora) : ano = agora.year, mes = agora.month;

  final AppDatabase db;
  final int ano;
  final int mes;
  final _categorias = <String, int>{};

  /// Dia [dia] do mês atual deslocado em [deslocamento] meses.
  DateTime dia(int deslocamento, int dia) => DateTime(ano, mes + deslocamento, dia);

  int categoria(String pai, [String? sub]) =>
      _categorias[sub == null ? pai : '$pai/$sub']!;

  Future<void> gerar() async {
    await _carregarCategorias();
    final criadoEm = DateTime.now().toIso8601String();

    // Contas, com saldo inicial no primeiro dia do mês anterior.
    final inicio = dataIso(dia(-1, 1));
    Future<int> conta(String nome, String tipo, int saldo) =>
        db.into(db.contas).insert(
          ContasCompanion.insert(
            nome: nome,
            tipo: tipo,
            saldoInicialCentavos: Value(saldo),
            dataSaldoInicial: inicio,
          ),
        );
    final carteira = await conta('Carteira', 'carteira', 40000);
    final nubank = await conta('Nubank', 'banco', 164000);
    final inter = await conta('Inter', 'banco', 10000);

    Future<_CartaoExemplo> cartao(String nome, int fecha, int vence, int contaId) async =>
        _CartaoExemplo(
          await db.into(db.cartoes).insert(
            CartoesCompanion.insert(
              nome: nome,
              diaFechamento: fecha,
              diaVencimento: vence,
              contaPagamentoId: contaId,
            ),
          ),
          fecha,
          vence,
        );
    final cartaoNubank = await cartao('Nubank', 5, 12, nubank);
    final cartaoInter = await cartao('Inter', 8, 15, inter);

    final trabalho = await db.into(db.tags).insert(TagsCompanion.insert(nome: 'trabalho'));
    await db.into(db.tags).insert(TagsCompanion.insert(nome: 'viagem'));

    Future<int> recorrencia(int diaDoMes) => db.into(db.recorrencias).insert(
      RecorrenciasCompanion.insert(
        diaDoMes: diaDoMes,
        dataInicio: dataIso(dia(-1, diaDoMes)),
      ),
    );

    Future<void> lancar({
      String tipo = 'despesa',
      required String descricao,
      required int valor,
      required DateTime data,
      int? contaId,
      _CartaoExemplo? noCartao,
      required List<(int, int)> categorias,
      List<int> tagIds = const [],
      int? parcelaAtual,
      int? totalParcelas,
      String? grupo,
      int? recorrenciaId,
    }) async {
      // Cada parcela vai para a fatura seguinte à anterior.
      final primeiraFatura = noCartao == null
          ? null
          : mesDaFatura(
              data,
              diaFechamento: noCartao.diaFechamento,
              diaVencimento: noCartao.diaVencimento,
            );
      final mesFatura = primeiraFatura == null
          ? null
          : mesIso(
              DateTime(primeiraFatura.year, primeiraFatura.month + (parcelaAtual ?? 1) - 1),
            );
      final id = await db.into(db.lancamentos).insert(
        LancamentosCompanion.insert(
          tipo: tipo,
          descricao: descricao,
          valorCentavos: valor,
          dataLancamento: dataIso(data),
          contaId: Value(contaId),
          cartaoId: Value(noCartao?.id),
          mesFatura: Value(mesFatura),
          mesReferencia: mesFatura ?? mesIso(data),
          parcelaAtual: Value(parcelaAtual),
          totalParcelas: Value(totalParcelas),
          grupoParcelamento: Value(grupo),
          recorrenciaId: Value(recorrenciaId),
          criadoEm: criadoEm,
        ),
      );
      for (final (categoriaId, valorCategoria) in categorias) {
        await db.into(db.lancamentoCategorias).insert(
          LancamentoCategoriasCompanion.insert(
            lancamentoId: id,
            categoriaId: categoriaId,
            valorCentavos: valorCategoria,
          ),
        );
      }
      for (final tagId in tagIds) {
        await db.into(db.lancamentoTags).insert(
          LancamentoTagsCompanion.insert(lancamentoId: id, tagId: tagId),
        );
      }
    }

    // Cartão Nubank
    await lancar(
      descricao: 'Mercado Atacadão',
      valor: 41230,
      data: dia(-1, 28),
      noCartao: cartaoNubank,
      categorias: [
        (categoria('Casa', 'Mercado'), 30000),
        (categoria('Casa', 'Limpeza'), 11230),
      ],
    );
    for (var parcela = 1; parcela <= 3; parcela++) {
      await lancar(
        descricao: 'Fone Bluetooth',
        valor: 10000,
        data: dia(-1, 25),
        noCartao: cartaoNubank,
        categorias: [(categoria('Compras', 'Eletrônicos'), 10000)],
        parcelaAtual: parcela,
        totalParcelas: 3,
        grupo: 'exemplo-fone-bluetooth',
      );
    }
    await lancar(
      descricao: 'Combustível',
      valor: 25000,
      data: dia(-1, 18),
      noCartao: cartaoNubank,
      categorias: [(categoria('Transporte', 'Combustível'), 25000)],
      tagIds: [trabalho],
    );
    await lancar(
      descricao: 'Restaurante',
      valor: 13600,
      data: dia(-1, 15),
      noCartao: cartaoNubank,
      categorias: [(categoria('Alimentação', 'Restaurantes'), 13600)],
    );
    await lancar(
      tipo: 'estorno',
      descricao: 'Restaurante',
      valor: 3000,
      data: dia(0, 2),
      noCartao: cartaoNubank,
      categorias: [(categoria('Alimentação', 'Restaurantes'), 3000)],
    );

    // Cartão Inter
    final netflix = await recorrencia(22);
    for (var deslocamento = -1; deslocamento <= 1; deslocamento++) {
      await lancar(
        descricao: 'Netflix',
        valor: 4490,
        data: dia(deslocamento, 22),
        noCartao: cartaoInter,
        categorias: [(categoria('Assinaturas', 'Streaming'), 4490)],
        recorrenciaId: netflix,
      );
    }
    await lancar(
      descricao: 'Farmácia',
      valor: 8760,
      data: dia(-1, 20),
      noCartao: cartaoInter,
      categorias: [(categoria('Saúde', 'Remédios'), 8760)],
    );

    // Contas
    final salario = await recorrencia(5);
    final aluguel = await recorrencia(10);
    for (var deslocamento = -1; deslocamento <= 1; deslocamento++) {
      await lancar(
        tipo: 'ganho',
        descricao: 'Salário',
        valor: 400000,
        data: dia(deslocamento, 5),
        contaId: nubank,
        categorias: [(categoria('Salário'), 400000)],
        recorrenciaId: salario,
      );
      await lancar(
        descricao: 'Aluguel',
        valor: 120000,
        data: dia(deslocamento, 10),
        contaId: inter,
        categorias: [(categoria('Casa', 'Aluguel'), 120000)],
        recorrenciaId: aluguel,
      );
    }
    await lancar(
      descricao: 'Padaria',
      valor: 1850,
      data: dia(0, 3),
      contaId: carteira,
      categorias: [(categoria('Alimentação', 'Lanches'), 1850)],
    );
    await lancar(
      descricao: 'Corrida de aplicativo',
      valor: 2340,
      data: dia(0, 1),
      contaId: nubank,
      categorias: [(categoria('Transporte', 'Aplicativos de corrida'), 2340)],
      tagIds: [trabalho],
    );

    await db.into(db.transferencias).insert(
      TransferenciasCompanion.insert(
        valorCentavos: 50000,
        contaOrigemId: nubank,
        contaDestinoId: inter,
        data: dataIso(dia(0, 9)),
        criadoEm: criadoEm,
      ),
    );

    await db.definirConfiguracao(ChaveConfiguracao.boasVindasConcluida, '1');
  }

  Future<void> _carregarCategorias() async {
    final todas = await db.select(db.categorias).get();
    final porId = {for (final c in todas) c.id: c};
    for (final c in todas) {
      final pai = c.categoriaPaiId == null ? null : porId[c.categoriaPaiId];
      // Despesa e ganho têm "Outros"; o de despesa fica com o nome simples.
      final chave = pai == null ? c.nome : '${pai.nome}/${c.nome}';
      _categorias.putIfAbsent(chave, () => c.id);
    }
  }
}
