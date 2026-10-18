import 'package:drift/drift.dart';

import '../../domain/exclusao.dart';
import '../database.dart';

/// Um lançamento ou uma transferência a excluir.
typedef AlvoExclusao = ({bool transferencia, int id});

/// O grupo de um lançamento ou de uma transferência: as parcelas da mesma
/// compra, os meses da mesma recorrência ou só ele mesmo.
class GrupoDoAlvo {
  const GrupoDoAlvo(this.tipo, this.membros);

  final TipoDeGrupo tipo;

  /// Inclui o próprio alvo.
  final List<MembroDoGrupo> membros;
}

/// O que uma exclusão tirou do banco, para o "Desfazer" devolver tudo como
/// estava, com os mesmos ids.
class Excluidos {
  const Excluidos({
    this.lancamentos = const [],
    this.categorias = const [],
    this.tags = const [],
    this.transferencias = const [],
    this.recorrencia,
  });

  final List<Lancamento> lancamentos;
  final List<LancamentoCategoria> categorias;
  final List<LancamentoTag> tags;
  final List<Transferencia> transferencias;

  /// A recorrência como estava, quando a exclusão mudou o fim dela.
  final Recorrencia? recorrencia;

  /// Quantos lançamentos ou transferências saíram.
  int get quantidade => lancamentos.length + transferencias.length;
}

/// Excluir lançamentos e transferências, sozinhos ou em grupo, e desfazer.
class ExclusaoDao extends DatabaseAccessor<AppDatabase> {
  ExclusaoDao(super.attachedDatabase);

  AppDatabase get _db => attachedDatabase;

  /// O grupo do [alvo]. Parcelas valem mais que recorrência.
  Future<GrupoDoAlvo> grupoDe(AlvoExclusao alvo) async {
    if (alvo.transferencia) {
      final transferencia = await _transferencia(alvo.id);
      final recorrenciaId = transferencia.recorrenciaId;
      if (recorrenciaId == null) {
        return GrupoDoAlvo(TipoDeGrupo.nenhum, [_membroT(transferencia)]);
      }
      final todas = await (select(
        _db.transferencias,
      )..where((t) => t.recorrenciaId.equals(recorrenciaId))).get();
      return GrupoDoAlvo(TipoDeGrupo.recorrencia, [for (final t in todas) _membroT(t)]);
    }

    final lancamento = await _lancamento(alvo.id);
    final grupo = lancamento.grupoParcelamento;
    final recorrenciaId = lancamento.recorrenciaId;
    if (grupo != null) {
      final parcelas = await (select(
        _db.lancamentos,
      )..where((l) => l.grupoParcelamento.equals(grupo))).get();
      return GrupoDoAlvo(TipoDeGrupo.parcelas, [for (final l in parcelas) _membroL(l)]);
    }
    if (recorrenciaId != null) {
      final meses = await (select(
        _db.lancamentos,
      )..where((l) => l.recorrenciaId.equals(recorrenciaId))).get();
      return GrupoDoAlvo(TipoDeGrupo.recorrencia, [for (final l in meses) _membroL(l)]);
    }
    return GrupoDoAlvo(TipoDeGrupo.nenhum, [_membroL(lancamento)]);
  }

  /// Exclui o [alvo] e, conforme o [alcance], os outros do grupo dele. Numa
  /// recorrência, "este e os próximos" encerra a recorrência no dia anterior
  /// e "todos" a desliga, para os meses seguintes não serem criados de novo.
  Future<Excluidos> excluir(AlvoExclusao alvo, AlcanceExclusao alcance) => transaction(() async {
    final grupo = await grupoDe(alvo);
    final ids = idsAExcluir(id: alvo.id, grupo: grupo.membros, alcance: alcance);
    final data = grupo.membros.firstWhere((m) => m.id == alvo.id).data;

    if (alvo.transferencia) {
      final transferencias =
          await (select(_db.transferencias)
                ..where((t) => t.id.isIn(ids))
                ..orderBy([(t) => OrderingTerm(expression: t.id)]))
              .get();
      final recorrencia = grupo.tipo == TipoDeGrupo.recorrencia
          ? await _encerrarRecorrencia(transferencias.first.recorrenciaId!, data, alcance)
          : null;
      await (delete(_db.transferencias)..where((t) => t.id.isIn(ids))).go();
      return Excluidos(transferencias: transferencias, recorrencia: recorrencia);
    }

    final lancamentos =
        await (select(_db.lancamentos)
              ..where((l) => l.id.isIn(ids))
              ..orderBy([(l) => OrderingTerm(expression: l.id)]))
            .get();
    final categorias =
        await (select(_db.lancamentoCategorias)
              ..where((c) => c.lancamentoId.isIn(ids))
              ..orderBy([(c) => OrderingTerm(expression: const CustomExpression<int>('rowid'))]))
            .get();
    final tags =
        await (select(_db.lancamentoTags)
              ..where((t) => t.lancamentoId.isIn(ids))
              ..orderBy([(t) => OrderingTerm(expression: const CustomExpression<int>('rowid'))]))
            .get();
    final recorrencia = grupo.tipo == TipoDeGrupo.recorrencia
        ? await _encerrarRecorrencia(lancamentos.first.recorrenciaId!, data, alcance)
        : null;
    // As categorias e as tags saem junto (ON DELETE CASCADE).
    await (delete(_db.lancamentos)..where((l) => l.id.isIn(ids))).go();
    return Excluidos(
      lancamentos: lancamentos,
      categorias: categorias,
      tags: tags,
      recorrencia: recorrencia,
    );
  });

  /// Devolve o que foi [excluidos], com os mesmos ids, e a recorrência como
  /// estava antes.
  Future<void> restaurar(Excluidos excluidos) => transaction(() async {
    for (final lancamento in excluidos.lancamentos) {
      await into(_db.lancamentos).insert(lancamento);
    }
    for (final categoria in excluidos.categorias) {
      await into(_db.lancamentoCategorias).insert(categoria);
    }
    for (final tag in excluidos.tags) {
      await into(_db.lancamentoTags).insert(tag);
    }
    for (final transferencia in excluidos.transferencias) {
      await into(_db.transferencias).insert(transferencia);
    }
    final recorrencia = excluidos.recorrencia;
    if (recorrencia != null) await update(_db.recorrencias).replace(recorrencia);
  });

  /// Encerra a recorrência [id] conforme o [alcance], a partir do
  /// lançamento de [data]. Devolve como ela estava, ou nulo se não mudou.
  Future<Recorrencia?> _encerrarRecorrencia(int id, String data, AlcanceExclusao alcance) async {
    if (alcance == AlcanceExclusao.soEste) return null;
    final antes = await (select(_db.recorrencias)..where((r) => r.id.equals(id))).getSingle();
    final consulta = update(_db.recorrencias)..where((r) => r.id.equals(id));
    if (alcance == AlcanceExclusao.todos) {
      await consulta.write(const RecorrenciasCompanion(ativa: Value(0)));
    } else {
      final fim = fimDaRecorrencia(data);
      final fimAtual = antes.dataFim;
      if (fimAtual != null && fimAtual.compareTo(fim) <= 0) return null;
      await consulta.write(RecorrenciasCompanion(dataFim: Value(fim)));
    }
    return antes;
  }

  Future<Lancamento> _lancamento(int id) =>
      (select(_db.lancamentos)..where((l) => l.id.equals(id))).getSingle();

  Future<Transferencia> _transferencia(int id) =>
      (select(_db.transferencias)..where((t) => t.id.equals(id))).getSingle();

  static MembroDoGrupo _membroL(Lancamento l) =>
      (id: l.id, data: l.dataLancamento, parcela: l.parcelaAtual);

  static MembroDoGrupo _membroT(Transferencia t) => (id: t.id, data: t.data, parcela: null);
}
