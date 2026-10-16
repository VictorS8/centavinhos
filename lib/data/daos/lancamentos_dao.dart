import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../../domain/datas.dart';
import '../../domain/lancamento.dart';
import '../database.dart';

/// A parte do valor de um lançamento que vai para uma categoria.
typedef ParteCategoria = ({int categoriaId, int valorCentavos});

/// Um ganho ou uma despesa como sai do formulário, pronto para gravar.
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
    required this.categorias,
    this.tags = const [],
    this.observacao,
  });

  /// 'ganho' ou 'despesa'.
  final String tipo;
  final String descricao;
  final int valorCentavos;
  final DateTime data;

  /// Conta ou cartão, nunca os dois.
  final int? contaId;
  final int? cartaoId;

  /// AAAA-MM, só no cartão.
  final String? mesFatura;

  /// Se o mês da fatura foi trocado à mão.
  final bool faturaManual;

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
  });

  final int? contaId;
  final int? cartaoId;
  final List<int> categoriaIds;
  final List<String> tags;

  /// Se a última vez foi um lançamento recorrente.
  final bool recorrente;
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
  /// Tudo vai de uma vez: o lançamento, as categorias e as tags. Devolve o id.
  ///
  /// Na edição, parcelas, recorrência e a data de criação ficam como estão.
  Future<int> salvar(DadosLancamento dados, {int? id}) {
    _conferir(dados);
    return transaction(() async {
      final tagIds = await _idsDasTags(dados.tags);
      final observacao = dados.observacao?.trim() ?? '';
      final campos = LancamentosCompanion(
        tipo: Value(dados.tipo),
        descricao: Value(limparNome(dados.descricao)),
        valorCentavos: Value(dados.valorCentavos),
        dataLancamento: Value(dataIso(dados.data)),
        contaId: Value(dados.contaId),
        cartaoId: Value(dados.cartaoId),
        mesFatura: Value(dados.mesFatura),
        faturaManual: Value(dados.faturaManual ? 1 : 0),
        mesReferencia: Value(mesReferencia(data: dados.data, mesFatura: dados.mesFatura)),
        observacao: Value(observacao.isEmpty ? null : observacao),
      );

      final int lancamentoId;
      if (id == null) {
        lancamentoId = await into(_lancamentos).insert(
          campos.copyWith(criadoEm: Value(DateTime.now().toIso8601String())),
        );
      } else {
        lancamentoId = id;
        await (update(_lancamentos)..where((l) => l.id.equals(id))).write(campos);
        await (delete(_categorias)..where((c) => c.lancamentoId.equals(id))).go();
        await (delete(_lancamentoTags)..where((t) => t.lancamentoId.equals(id))).go();
      }

      for (final parte in dados.categorias) {
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
      return lancamentoId;
    });
  }

  /// Confere de novo o que o formulário já trava, para nunca gravar um
  /// lançamento quebrado.
  static void _conferir(DadosLancamento dados) {
    if (dados.tipo != 'ganho' && dados.tipo != 'despesa') {
      throw ArgumentError.value(dados.tipo, 'tipo', 'deve ser ganho ou despesa');
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
