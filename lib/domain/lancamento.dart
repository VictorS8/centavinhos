// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

/// Regras do formulário de lançamento.
library;

import 'cadastros.dart';
import 'datas.dart';
import 'multicategoria.dart';
import 'parcelas.dart';

/// Mês em que o lançamento conta nos totais e filtros: o da fatura, no
/// cartão, ou o da data de lançamento, nas contas. Formato AAAA-MM.
String mesReferencia({required DateTime data, String? mesFatura}) =>
    mesFatura ?? mesIso(data);

/// Por que o lançamento não pode ser salvo, ou nulo se pode.
///
/// [tipo] é 'ganho', 'despesa' ou 'estorno'. [valoresCategorias] são os
/// valores digitados para cada categoria. Com uma categoria só, o valor dela
/// é o total e ela pode vir com zero. [temOrigem] diz se a conta ou o cartão
/// foi escolhido. [data] é nula quando o texto do campo não é uma data
/// válida. [parcelas] é o número de parcelas de uma compra parcelada (zero
/// com o campo vazio), ou nulo quando ela não é parcelada. O estorno e a
/// compra parcelada só podem ser no cartão.
String? motivoLancamentoInvalido({
  required String tipo,
  required String nome,
  required int valorCentavos,
  required List<int> valoresCategorias,
  required bool temOrigem,
  required DateTime? data,
  int? parcelas,
}) {
  if (limparNome(nome).isEmpty) return 'Dê um nome ao lançamento.';
  if (valorCentavos <= 0) return 'Digite o valor.';
  if (parcelas != null) {
    if (parcelas < minimoDeParcelas || parcelas > maximoDeParcelas) {
      return 'Parcelas vão de $minimoDeParcelas a $maximoDeParcelas.';
    }
    if (valorCentavos < parcelas) return 'O valor não dá R\$ 0,01 por parcela.';
  }
  if (valoresCategorias.isEmpty) return 'Escolha uma categoria.';
  if (valoresCategorias.length > 1 &&
      !Distribuicao(total: valorCentavos, valores: valoresCategorias).fecha) {
    return 'Distribua o valor entre as categorias.';
  }
  if (!temOrigem) {
    if (tipo == 'ganho') return 'Escolha a conta.';
    if (tipo == 'estorno' || parcelas != null) return 'Escolha o cartão.';
    return 'Escolha a conta ou o cartão.';
  }
  if (data == null) return 'Data inválida. Use dd/mm ou dd/mm/aaaa.';
  return null;
}
