/// Regras de exclusão de lançamentos parcelados e recorrentes.
library;

import 'datas.dart';

/// O que excluir quando o lançamento faz parte de um grupo.
enum AlcanceExclusao { soEste, esteEOsProximos, todos }

/// Que grupo um lançamento ou uma transferência forma com os outros.
enum TipoDeGrupo { nenhum, parcelas, recorrencia }

/// Um lançamento (ou uma transferência) do grupo. [data] é AAAA-MM-DD e
/// [parcela], a parcela atual, só nas parcelas.
typedef MembroDoGrupo = ({int id, String data, int? parcela});

/// Ordem dentro do grupo: pela parcela, quando há, ou pela data; no
/// empate, pelo id.
int _compararMembros(MembroDoGrupo a, MembroDoGrupo b) {
  if (a.parcela != null && b.parcela != null && a.parcela != b.parcela) {
    return a.parcela!.compareTo(b.parcela!);
  }
  final porData = a.data.compareTo(b.data);
  return porData != 0 ? porData : a.id.compareTo(b.id);
}

/// Ids a excluir do [grupo] (que inclui o próprio lançamento [id]), na
/// ordem do grupo.
///
/// "Este e os próximos" pega o lançamento e os que vêm depois dele: as
/// parcelas seguintes, ou os meses seguintes de uma recorrência.
List<int> idsAExcluir({
  required int id,
  required List<MembroDoGrupo> grupo,
  required AlcanceExclusao alcance,
}) {
  final ordenado = [...grupo]..sort(_compararMembros);
  final este = ordenado.firstWhere((membro) => membro.id == id);
  return [
    for (final membro in ordenado)
      if (switch (alcance) {
        AlcanceExclusao.soEste => membro.id == id,
        AlcanceExclusao.esteEOsProximos => _compararMembros(membro, este) >= 0,
        AlcanceExclusao.todos => true,
      })
        membro.id,
  ];
}

/// Último dia de uma recorrência que perde o lançamento de [data] e os
/// seguintes: o dia anterior. Recebe e devolve AAAA-MM-DD.
String fimDaRecorrencia(String data) {
  final dia = lerDataIso(data);
  return dataIso(DateTime(dia.year, dia.month, dia.day - 1));
}
