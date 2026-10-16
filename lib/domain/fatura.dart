/// Regra da fatura do cartão: em que mês uma compra é cobrada.
library;

import 'datas.dart';

/// Mês da fatura de uma compra feita em [data], num cartão que fecha no dia
/// [diaFechamento] e vence no dia [diaVencimento]. O mês da fatura é o mês
/// do vencimento; devolve o primeiro dia dele.
///
/// 1. Compra antes do fechamento entra na fatura que fecha naquele mês.
/// 2. Compra no dia do fechamento ou depois entra na fatura seguinte.
/// 3. Se o vencimento for menor que o fechamento (fecha 28, vence 5), ele cai
///    no mês seguinte ao fechamento.
/// 4. Fechamento num dia que não existe no mês vira o último dia do mês.
DateTime mesDaFatura(
  DateTime data, {
  required int diaFechamento,
  required int diaVencimento,
}) {
  final fechamento = diaNoMes(data.year, data.month, diaFechamento);
  final mesFechamento = data.day < fechamento.day ? data.month : data.month + 1;
  final mesVencimento = mesFechamento + (diaVencimento < diaFechamento ? 1 : 0);
  return DateTime(data.year, mesVencimento);
}

/// Dia do vencimento da fatura do [mes]. Vencimento num dia que não existe
/// no mês vira o último dia do mês.
DateTime vencimentoDaFatura(DateTime mes, {required int diaVencimento}) =>
    diaNoMes(mes.year, mes.month, diaVencimento);
