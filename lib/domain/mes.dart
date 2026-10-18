/// Regras da tela do mês: como cada lançamento aparece na lista e o total
/// de gastos.
library;

import 'datas.dart';
import 'dinheiro.dart';

/// Uma categoria de um lançamento da lista, com a parte do valor dela.
/// [rotulo] é "Casa, Mercado" (ou só "Casa", numa principal) e [principal]
/// é a categoria principal ("Casa").
typedef CategoriaDoItem = ({String rotulo, String principal, int valorCentavos});

/// Nome com a parcela atual, como "Fone (2/3)", quando é parcelado.
String nomeComParcela(String descricao, {int? parcelaAtual, int? totalParcelas}) =>
    parcelaAtual == null || totalParcelas == null
    ? descricao
    : '$descricao ($parcelaAtual/$totalParcelas)';

/// Um lançamento ou uma transferência como aparece na lista do mês.
class ItemDoMes {
  const ItemDoMes({
    required this.tipo,
    required this.id,
    required this.descricao,
    required this.valorCentavos,
    required this.data,
    this.categorias = const [],
    this.conta,
    this.cartao,
    this.vencimento,
    this.contaDestino,
    this.parcelaAtual,
    this.totalParcelas,
    this.mensal = false,
  });

  /// 'ganho', 'despesa', 'estorno' ou 'transferencia'.
  final String tipo;

  /// Id do lançamento ou, numa transferência, da transferência.
  final int id;
  final String descricao;
  final int valorCentavos;

  /// Data de lançamento ou, numa transferência, a data dela.
  final DateTime data;

  /// Na ordem em que foram escolhidas. Transferências não têm.
  final List<CategoriaDoItem> categorias;

  /// Nome da conta. Numa transferência, a conta de origem.
  final String? conta;

  /// Nome do cartão e o dia de vencimento da fatura, só no cartão.
  final String? cartao;
  final DateTime? vencimento;

  /// Conta de destino, só na transferência.
  final String? contaDestino;
  final int? parcelaAtual;
  final int? totalParcelas;

  /// Se é um lançamento recorrente.
  final bool mensal;

  bool get transferencia => tipo == 'transferencia';

  /// Nome na lista: com a parcela ("Fone (2/3)") ou, na transferência,
  /// gerado pelas contas ("Transferência Nubank para Inter").
  String get nome => transferencia
      ? 'Transferência $conta para $contaDestino'
      : nomeComParcela(descricao, parcelaAtual: parcelaAtual, totalParcelas: totalParcelas);

  /// Letra do círculo: a inicial da categoria principal da primeira
  /// categoria. Transferências usam um ícone.
  String get inicial {
    final principal = categorias.firstOrNull?.principal ?? '';
    return principal.isEmpty ? '?' : principal.substring(0, 1).toUpperCase();
  }

  /// Quantas categorias além da primeira, para a etiqueta "+1 categoria".
  int get categoriasAMais => categorias.isEmpty ? 0 : categorias.length - 1;

  /// Linha de baixo: a primeira categoria e a conta ou o cartão, como
  /// "Casa, Mercado · Nubank, vence 12/10". Na transferência, "Nubank →
  /// Inter".
  String get detalhe {
    if (transferencia) return '$conta → $contaDestino';
    final origem = cartao == null
        ? conta ?? ''
        : vencimento == null
        ? cartao!
        : '$cartao, vence ${diaMesBr(vencimento!)}';
    final categoria = categorias.firstOrNull?.rotulo;
    return categoria == null ? origem : '$categoria · $origem';
  }

  /// Valor na lista: "+R$" no ganho, "−R$" no estorno e sem sinal no resto.
  String get valorNaLista => switch (tipo) {
    'ganho' => '+${formatarCentavos(valorCentavos)}',
    'estorno' => formatarCentavos(valorCentavos, negativo: true),
    _ => formatarCentavos(valorCentavos),
  };
}

/// Total de gastos: despesas menos estornos. Ganhos e transferências ficam
/// de fora.
int totalDeGastos(Iterable<ItemDoMes> itens) => itens.fold(
  0,
  (total, item) => switch (item.tipo) {
    'despesa' => total + item.valorCentavos,
    'estorno' => total - item.valorCentavos,
    _ => total,
  },
);

/// Ordem da lista: da data mais recente para a mais antiga. No mesmo dia,
/// os lançamentos vêm antes das transferências, e o último criado primeiro.
List<ItemDoMes> ordenarParaLista(Iterable<ItemDoMes> itens) => [...itens]
  ..sort((a, b) {
    final porData = b.data.compareTo(a.data);
    if (porData != 0) return porData;
    if (a.transferencia != b.transferencia) return a.transferencia ? 1 : -1;
    return b.id.compareTo(a.id);
  });
