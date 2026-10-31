// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../../domain/datas.dart';
import '../../domain/exclusao.dart';
import '../../domain/lancamento.dart';
import '../../domain/parcelas.dart';
import '../database.dart';

/// A parte do valor de um lançamento que vai para uma categoria.
typedef ParteCategoria = ({int categoriaId, int valorCentavos});

/// Um ganho, uma despesa ou um estorno como sai do formulário, pronto para
/// gravar.
class DadosLancamento {
  const DadosLancamento({
    required this.tipo,
    required this.descricao,
    required this.valorCentavos,
    required this.data,
    this.contaId,
    this.cartaoId,
    this.mesFatura,
    this.faturaManual = false,
    this.parcelas,
    required this.categorias,
    this.tags = const [],
    this.observacao,
  });

  /// 'ganho', 'despesa' ou 'estorno' (só no cartão).
  final String tipo;
  final String descricao;

  /// Numa compra parcelada nova, o total da compra; na edição de uma
  /// parcela, o valor da parcela.
  final int valorCentavos;
  final DateTime data;

  /// Conta ou cartão, nunca os dois.
  final int? contaId;
  final int? cartaoId;

  /// AAAA-MM, só no cartão. Numa compra parcelada nova, o da primeira
  /// parcela; na edição de uma parcela, o da parcela aberta.
  final String? mesFatura;

  /// Se o mês da fatura foi trocado à mão.
  final bool faturaManual;

  /// Em quantas vezes a compra nova é parcelada, ou nulo se não é. Só numa
  /// despesa no cartão, e só ao criar.
  final int? parcelas;

  /// Com uma categoria só, o valor dela é o total.
  final List<ParteCategoria> categorias;

  /// Nomes das tags. As que não existem são criadas ao salvar.
  final List<String> tags;
  final String? observacao;
}

/// Um lançamento gravado, com as categorias e as tags dele.
class LancamentoCompleto {
  const LancamentoCompleto(this.lancamento, this.categorias, this.tags);

  final Lancamento lancamento;
  final List<ParteCategoria> categorias;
  final List<String> tags;
}

/// O que um nome conhecido preenche, tirado da última vez em que ele foi
/// usado. Contas, cartões, categorias e tags arquivados ficam de fora.
class Preenchimento {
  const Preenchimento({
    this.contaId,
    this.cartaoId,
    required this.categoriaIds,
    required this.tags,
    required this.recorrente,
    this.parcelas,
  });

  final int? contaId;
  final int? cartaoId;
  final List<int> categoriaIds;
  final List<String> tags;

  /// Se a última vez foi um lançamento recorrente.
  final bool recorrente;

  /// Em quantas vezes foi parcelada a última vez, ou nulo se não foi.
  final int? parcelas;
}

/// Lançamentos: gravar, carregar e os nomes já usados.
class LancamentosDao extends DatabaseAccessor<AppDatabase> {
  LancamentosDao(super.attachedDatabase);

  Lancamentos get _lancamentos => attachedDatabase.lancamentos;
  LancamentoCategorias get _categorias => attachedDatabase.lancamentoCategorias;
  LancamentoTags get _lancamentoTags => attachedDatabase.lancamentoTags;
  Tags get _tags => attachedDatabase.tags;

  /// Nomes já usados em lançamentos do [tipo], do mais recente para o mais
  /// antigo, sem repetir.
  Stream<List<String>> observarNomes(String tipo) => customSelect(
    'SELECT descricao FROM lancamentos WHERE tipo = ? '
    'GROUP BY descricao ORDER BY MAX(id) DESC',
    variables: [Variable.withString(tipo)],
    readsFrom: {_lancamentos},
  ).watch().map((linhas) => [for (final linha in linhas) linha.read<String>('descricao')]);

  /// O que preencher ao escolher o nome [descricao] num lançamento do
  /// [tipo], ou nulo se o nome nunca foi usado nesse tipo.
  Future<Preenchimento?> ultimoComNome(String descricao, String tipo) async {
    final ultimo = await (select(_lancamentos)
          ..where((l) => l.descricao.equals(descricao) & l.tipo.equals(tipo))
          ..orderBy([(l) => OrderingTerm.desc(l.id)])
          ..limit(1))
        .getSingleOrNull();
    if (ultimo == null) return null;

    final contas = attachedDatabase.contas;
    final cartoes = attachedDatabase.cartoes;
    final contaAtiva = ultimo.contaId == null
        ? false
        : await (select(contas)
                ..where((c) => c.id.equals(ultimo.contaId!) & c.arquivada.equals(0)))
              .getSingleOrNull() !=
            null;
    final cartaoAtivo = ultimo.cartaoId == null
        ? false
        : await (select(cartoes)
                ..where((c) => c.id.equals(ultimo.cartaoId!) & c.arquivado.equals(0)))
              .getSingleOrNull() !=
            null;

    final categoriaIds = await customSelect(
      'SELECT lc.categoria_id FROM lancamento_categorias lc '
      'JOIN categorias c ON c.id = lc.categoria_id '
      'WHERE lc.lancamento_id = ? AND c.arquivada = 0 ORDER BY lc.rowid',
      variables: [Variable.withInt(ultimo.id)],
      readsFrom: {_categorias, attachedDatabase.categorias},
    ).map((linha) => linha.read<int>('categoria_id')).get();

    return Preenchimento(
      contaId: contaAtiva ? ultimo.contaId : null,
      cartaoId: cartaoAtivo ? ultimo.cartaoId : null,
      categoriaIds: categoriaIds,
      tags: await _nomesDasTags(ultimo.id, soAtivas: true),
      recorrente: ultimo.recorrenciaId != null,
      parcelas: ultimo.totalParcelas,
    );
  }

  /// O lançamento [id], com as categorias e as tags, para editar.
  Future<LancamentoCompleto> carregar(int id) async {
    final lancamento = await (select(_lancamentos)..where((l) => l.id.equals(id))).getSingle();
    final partes = await (select(_categorias)
          ..where((c) => c.lancamentoId.equals(id))
          ..orderBy([(c) => OrderingTerm(expression: const CustomExpression<int>('rowid'))]))
        .map((c) => (categoriaId: c.categoriaId, valorCentavos: c.valorCentavos))
        .get();
    return LancamentoCompleto(lancamento, partes, await _nomesDasTags(id));
  }

  Future<List<String>> _nomesDasTags(int lancamentoId, {bool soAtivas = false}) => customSelect(
    'SELECT t.nome FROM lancamento_tags lt JOIN tags t ON t.id = lt.tag_id '
    'WHERE lt.lancamento_id = ?${soAtivas ? ' AND t.arquivada = 0' : ''} ORDER BY lt.rowid',
    variables: [Variable.withInt(lancamentoId)],
    readsFrom: {_lancamentoTags, _tags},
  ).map((linha) => linha.read<String>('nome')).get();

  /// Grava um lançamento novo ou, com [id], troca os dados de um existente.
  /// Tudo vai de uma vez: o lançamento, as categorias e as tags. Devolve o id
  /// (numa compra parcelada nova, o da primeira parcela).
  ///
  /// Uma compra parcelada nova vira uma linha por parcela, ligadas pelo
  /// mesmo grupo de parcelamento (o id da primeira, em texto). Cada parcela
  /// cai no mês seguinte ao da anterior, e os centavos que sobram da divisão
  /// vão para a primeira.
  ///
  /// Na edição, parcelas, recorrência e a data de criação ficam como estão.
  /// Numa parcela, o [alcance] diz se a mudança vale só para ela, para ela e
  /// as seguintes ou para todas; cada parcela mantém a sua distância da
  /// aberta na sequência das faturas.
  Future<int> salvar(
    DadosLancamento dados, {
    int? id,
    AlcanceExclusao alcance = AlcanceExclusao.soEste,
  }) {
    _conferir(dados, editando: id != null);
    return transaction(() async {
      final tagIds = await _idsDasTags(dados.tags);
      if (id != null) {
        await _editar(dados, id, alcance, tagIds);
        return id;
      }

      final n = dados.parcelas;
      if (n == null) {
        final campos = _campos(dados, dados.valorCentavos, dados.mesFatura);
        return _inserir(campos, dados.categorias, tagIds);
      }

      final valores = dividirEmParcelas(dados.valorCentavos, n);
      final porParcela = dividirCategoriasEmParcelas([
        for (final parte in dados.categorias) parte.valorCentavos,
      ], n);
      final primeiraFatura = lerMesIso(dados.mesFatura!);
      late final int primeiraId;
      for (var i = 0; i < n; i++) {
        final mesFatura = mesIso(DateTime(primeiraFatura.year, primeiraFatura.month + i));
        final campos = _campos(dados, valores[i], mesFatura).copyWith(
          parcelaAtual: Value(i + 1),
          totalParcelas: Value(n),
          grupoParcelamento: Value(i == 0 ? null : '$primeiraId'),
        );
        final partes = [
          for (final (j, parte) in dados.categorias.indexed)
            // O banco não aceita zero; só acontece com poucos centavos.
            if (porParcela[i][j] > 0)
              (categoriaId: parte.categoriaId, valorCentavos: porParcela[i][j]),
        ];
        final parcelaId = await _inserir(campos, partes, tagIds);
        if (i == 0) {
          primeiraId = parcelaId;
          await (update(_lancamentos)..where((l) => l.id.equals(parcelaId))).write(
            LancamentosCompanion(grupoParcelamento: Value('$parcelaId')),
          );
        }
      }
      return primeiraId;
    });
  }

  /// Troca os dados do lançamento [id] e, numa parcela, das outras que o
  /// [alcance] pega.
  Future<void> _editar(
    DadosLancamento dados,
    int id,
    AlcanceExclusao alcance,
    List<int> tagIds,
  ) async {
    final aberto = await (select(_lancamentos)..where((l) => l.id.equals(id))).getSingle();
    var alvos = [aberto];
    final grupo = aberto.grupoParcelamento;
    if (grupo != null && alcance != AlcanceExclusao.soEste) {
      final parcelas = await (select(
        _lancamentos,
      )..where((l) => l.grupoParcelamento.equals(grupo))).get();
      final ids = idsNoAlcance(
        id: id,
        grupo: [
          for (final p in parcelas) (id: p.id, data: p.dataLancamento, parcela: p.parcelaAtual),
        ],
        alcance: alcance,
      );
      alvos = [for (final p in parcelas) if (ids.contains(p.id)) p];
    }

    for (final alvo in alvos) {
      final distancia = (alvo.parcelaAtual ?? 1) - (aberto.parcelaAtual ?? 1);
      final mesAberto = dados.mesFatura == null ? null : lerMesIso(dados.mesFatura!);
      final mesFatura = mesAberto == null
          ? null
          : mesIso(DateTime(mesAberto.year, mesAberto.month + distancia));
      await (update(_lancamentos)..where((l) => l.id.equals(alvo.id))).write(
        _campos(dados, dados.valorCentavos, mesFatura),
      );
      await (delete(_categorias)..where((c) => c.lancamentoId.equals(alvo.id))).go();
      await (delete(_lancamentoTags)..where((t) => t.lancamentoId.equals(alvo.id))).go();
      await _gravarPartes(alvo.id, dados.categorias, tagIds);
    }
  }

  /// Campos de um lançamento com o [valor] e o [mesFatura] dados.
  static LancamentosCompanion _campos(DadosLancamento dados, int valor, String? mesFatura) {
    final observacao = dados.observacao?.trim() ?? '';
    return LancamentosCompanion(
      tipo: Value(dados.tipo),
      descricao: Value(limparNome(dados.descricao)),
      valorCentavos: Value(valor),
      dataLancamento: Value(dataIso(dados.data)),
      contaId: Value(dados.contaId),
      cartaoId: Value(dados.cartaoId),
      mesFatura: Value(mesFatura),
      faturaManual: Value(dados.faturaManual ? 1 : 0),
      mesReferencia: Value(mesReferencia(data: dados.data, mesFatura: mesFatura)),
      observacao: Value(observacao.isEmpty ? null : observacao),
    );
  }

  Future<int> _inserir(
    LancamentosCompanion campos,
    List<ParteCategoria> categorias,
    List<int> tagIds,
  ) async {
    final id = await into(_lancamentos).insert(
      campos.copyWith(criadoEm: Value(DateTime.now().toIso8601String())),
    );
    await _gravarPartes(id, categorias, tagIds);
    return id;
  }

  Future<void> _gravarPartes(int lancamentoId, List<ParteCategoria> categorias, List<int> tagIds) async {
    for (final parte in categorias) {
      await into(_categorias).insert(
        LancamentoCategoriasCompanion.insert(
          lancamentoId: lancamentoId,
          categoriaId: parte.categoriaId,
          valorCentavos: parte.valorCentavos,
        ),
      );
    }
    for (final tagId in tagIds) {
      await into(_lancamentoTags).insert(
        LancamentoTagsCompanion.insert(lancamentoId: lancamentoId, tagId: tagId),
      );
    }
  }

  /// Confere de novo o que o formulário já trava, para nunca gravar um
  /// lançamento quebrado.
  static void _conferir(DadosLancamento dados, {required bool editando}) {
    if (!const ['ganho', 'despesa', 'estorno'].contains(dados.tipo)) {
      throw ArgumentError.value(dados.tipo, 'tipo', 'deve ser ganho, despesa ou estorno');
    }
    if (dados.tipo == 'estorno' && dados.cartaoId == null) {
      throw ArgumentError.value(dados.cartaoId, 'cartaoId', 'estorno só no cartão');
    }
    final parcelas = dados.parcelas;
    if (parcelas != null) {
      if (editando) {
        throw ArgumentError.value(parcelas, 'parcelas', 'não muda na edição');
      }
      if (dados.tipo != 'despesa' || dados.cartaoId == null) {
        throw ArgumentError.value(parcelas, 'parcelas', 'só em despesa no cartão');
      }
      if (parcelas < minimoDeParcelas ||
          parcelas > maximoDeParcelas ||
          dados.valorCentavos < parcelas) {
        throw ArgumentError.value(parcelas, 'parcelas', 'fora do limite ou maior que o valor');
      }
    }
    if (dados.categorias.isEmpty) {
      throw ArgumentError.value(dados.categorias, 'categorias', 'precisa de ao menos uma');
    }
    final soma = dados.categorias.fold(0, (total, parte) => total + parte.valorCentavos);
    if (soma != dados.valorCentavos) {
      throw ArgumentError.value(soma, 'categorias', 'a soma deve ser ${dados.valorCentavos}');
    }
    if (dados.cartaoId != null && dados.mesFatura == null) {
      throw ArgumentError.value(dados.mesFatura, 'mesFatura', 'obrigatório no cartão');
    }
    if (dados.cartaoId == null && dados.mesFatura != null) {
      throw ArgumentError.value(dados.mesFatura, 'mesFatura', 'só no cartão');
    }
  }

  /// Ids das tags com os [nomes], sem repetir. Um nome que ainda não existe
  /// vira uma tag nova; um que é de uma tag arquivada desarquiva a tag.
  Future<List<int>> _idsDasTags(List<String> nomes) async {
    final todas = await select(_tags).get();
    final ids = <int>[];
    for (final nome in nomes) {
      final limpo = limparNomeTag(nome);
      if (limpo.isEmpty) continue;
      final existente = todas.where((t) => chaveDoNome(t.nome) == chaveDoNome(limpo)).firstOrNull;
      final int id;
      if (existente == null) {
        id = await attachedDatabase.tagsDao.criar(limpo);
        todas.add(Tag(id: id, nome: limpo, arquivada: 0));
      } else {
        id = existente.id;
        if (existente.arquivada == 1) await attachedDatabase.tagsDao.desarquivar(id);
      }
      if (!ids.contains(id)) ids.add(id);
    }
    return ids;
  }
}
