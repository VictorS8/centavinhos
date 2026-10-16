/// Regras do formulário de lançamento.
library;

import 'cadastros.dart';
import 'datas.dart';
import 'multicategoria.dart';

/// Mês em que o lançamento conta nos totais e filtros: o da fatura, no
/// cartão, ou o da data de lançamento, nas contas. Formato AAAA-MM.
String mesReferencia({required DateTime data, String? mesFatura}) =>
    mesFatura ?? mesIso(data);

/// Por que o lançamento não pode ser salvo, ou nulo se pode.
///
/// [valoresCategorias] são os valores digitados para cada categoria. Com uma
/// categoria só, o valor dela é o total e ela pode vir com zero.
/// [temOrigem] diz se a conta ou o cartão foi escolhido. [data] é nula
/// quando o texto do campo não é uma data válida.
String? motivoLancamentoInvalido({
  required String tipo,
  required String nome,
  required int valorCentavos,
  required List<int> valoresCategorias,
  required bool temOrigem,
  required DateTime? data,
}) {
  if (limparNome(nome).isEmpty) return 'Dê um nome ao lançamento.';
  if (valorCentavos <= 0) return 'Digite o valor.';
  if (valoresCategorias.isEmpty) return 'Escolha uma categoria.';
  if (valoresCategorias.length > 1 &&
      !Distribuicao(total: valorCentavos, valores: valoresCategorias).fecha) {
    return 'Distribua o valor entre as categorias.';
  }
  if (!temOrigem) return tipo == 'ganho' ? 'Escolha a conta.' : 'Escolha a conta ou o cartão.';
  if (data == null) return 'Data inválida. Use dd/mm ou dd/mm/aaaa.';
  return null;
}
