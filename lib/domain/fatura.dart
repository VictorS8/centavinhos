// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

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

/// Mês da fatura da parcela [parcela] (1 para a primeira) de uma compra
/// feita em [data]: a primeira cai no mês da fatura da compra, e cada uma
/// das outras, no mês seguinte ao da anterior.
DateTime mesDaFaturaDaParcela(
  DateTime data, {
  required int parcela,
  required int diaFechamento,
  required int diaVencimento,
}) {
  final primeira = mesDaFatura(
    data,
    diaFechamento: diaFechamento,
    diaVencimento: diaVencimento,
  );
  return DateTime(primeira.year, primeira.month + parcela - 1);
}

/// Mês da fatura (AAAA-MM) de um lançamento depois que o fechamento ou o
/// vencimento do cartão mudou, ou nulo se ele não muda: quando foi trocado
/// à mão ([manual]) ou já está no mês certo. [data] é a data de lançamento
/// (AAAA-MM-DD) e [parcela], a parcela atual, nas compras parceladas.
String? faturaRecalculada({
  required String data,
  required String mesAtual,
  required bool manual,
  int? parcela,
  required int diaFechamento,
  required int diaVencimento,
}) {
  if (manual) return null;
  final novo = mesIso(
    mesDaFaturaDaParcela(
      lerDataIso(data),
      parcela: parcela ?? 1,
      diaFechamento: diaFechamento,
      diaVencimento: diaVencimento,
    ),
  );
  return novo == mesAtual ? null : novo;
}

/// Dia em que fecha a fatura do [mes] (o mês do vencimento). Quando o
/// vencimento é menor que o fechamento, ela fecha no mês anterior.
DateTime fechamentoDaFatura(
  DateTime mes, {
  required int diaFechamento,
  required int diaVencimento,
}) => diaNoMes(
  mes.year,
  mes.month - (diaVencimento < diaFechamento ? 1 : 0),
  diaFechamento,
);

/// Em que pé está uma fatura em relação a hoje.
enum SituacaoFatura {
  /// Ainda não é a fatura das compras de hoje.
  futura,

  /// Recebe as compras feitas hoje.
  aberta,

  /// Já fechou, mas ainda não venceu.
  fechada,

  /// Venceu: saiu do saldo da conta de pagamento.
  paga,
}

/// Situação da fatura do [mes] em [hoje]. Ela é paga no dia do vencimento
/// e fecha no dia do fechamento (a compra desse dia já vai para a
/// seguinte).
SituacaoFatura situacaoDaFatura(
  DateTime mes, {
  required DateTime hoje,
  required int diaFechamento,
  required int diaVencimento,
}) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  if (!vencimentoDaFatura(mes, diaVencimento: diaVencimento).isAfter(dia)) {
    return SituacaoFatura.paga;
  }
  final fechamento = fechamentoDaFatura(
    mes,
    diaFechamento: diaFechamento,
    diaVencimento: diaVencimento,
  );
  if (!fechamento.isAfter(dia)) return SituacaoFatura.fechada;
  final aberta = mesDaFatura(dia, diaFechamento: diaFechamento, diaVencimento: diaVencimento);
  return mes == aberta ? SituacaoFatura.aberta : SituacaoFatura.futura;
}

/// O que um cartão tem lançado na fatura de um mês (AAAA-MM): a soma das
/// compras, a dos estornos e quantos lançamentos são.
typedef MovimentoDaFatura = ({String mes, int compras, int estornos, int lancamentos});

/// Uma fatura de um cartão, como aparece na tela de Cartões.
class FaturaDoCartao {
  const FaturaDoCartao({
    required this.mes,
    required this.fechamento,
    required this.vencimento,
    required this.situacao,
    required this.compras,
    required this.estornos,
    required this.lancamentos,
    required this.creditoAnterior,
    required this.total,
    required this.creditoSeguinte,
  });

  /// Primeiro dia do mês da fatura (o do vencimento).
  final DateTime mes;
  final DateTime fechamento;
  final DateTime vencimento;
  final SituacaoFatura situacao;
  final int compras;
  final int estornos;
  final int lancamentos;

  /// Crédito que sobrou das faturas anteriores e abate esta.
  final int creditoAnterior;

  /// Compras − estornos − crédito anterior, nunca abaixo de zero.
  final int total;

  /// O que sobra para abater a fatura seguinte, quando os estornos e o
  /// crédito passam das compras.
  final int creditoSeguinte;
}

/// As faturas de um cartão, da mais recente para a mais antiga: uma por mês
/// com algum lançamento e, mesmo vazia, a fatura aberta de [hoje].
///
/// Total da fatura = compras − estornos − crédito anterior. Se der
/// negativo, a fatura fica em zero e a sobra vira crédito para a seguinte,
/// e assim por diante até acabar.
List<FaturaDoCartao> faturasDoCartao(
  Iterable<MovimentoDaFatura> movimentos, {
  required DateTime hoje,
  required int diaFechamento,
  required int diaVencimento,
}) {
  final porMes = {for (final m in movimentos) m.mes: m};
  final aberta = mesIso(
    mesDaFatura(hoje, diaFechamento: diaFechamento, diaVencimento: diaVencimento),
  );
  porMes.putIfAbsent(aberta, () => (mes: aberta, compras: 0, estornos: 0, lancamentos: 0));

  final faturas = <FaturaDoCartao>[];
  var credito = 0;
  for (final mesIsoTexto in porMes.keys.toList()..sort()) {
    final m = porMes[mesIsoTexto]!;
    final mes = lerMesIso(m.mes);
    final saldo = m.compras - m.estornos - credito;
    faturas.add(
      FaturaDoCartao(
        mes: mes,
        fechamento: fechamentoDaFatura(
          mes,
          diaFechamento: diaFechamento,
          diaVencimento: diaVencimento,
        ),
        vencimento: vencimentoDaFatura(mes, diaVencimento: diaVencimento),
        situacao: situacaoDaFatura(
          mes,
          hoje: hoje,
          diaFechamento: diaFechamento,
          diaVencimento: diaVencimento,
        ),
        compras: m.compras,
        estornos: m.estornos,
        lancamentos: m.lancamentos,
        creditoAnterior: credito,
        total: saldo > 0 ? saldo : 0,
        creditoSeguinte: saldo < 0 ? -saldo : 0,
      ),
    );
    credito = saldo < 0 ? -saldo : 0;
  }
  return faturas.reversed.toList();
}
