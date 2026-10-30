import 'package:drift/drift.dart';

import '../../domain/fatura.dart';
import '../database.dart';

/// Faturas dos cartões. O total não é guardado: sai da soma dos lançamentos
/// do cartão em cada mês da fatura.
class FaturasDao extends DatabaseAccessor<AppDatabase> {
  FaturasDao(super.attachedDatabase);

  /// O que o cartão [cartaoId] tem em cada mês da fatura: compras, estornos
  /// e quantos lançamentos. Atualiza sozinho quando algo muda.
  Stream<List<MovimentoDaFatura>> observar(int cartaoId) => customSelect(
    "SELECT mes_fatura, "
    "SUM(CASE WHEN tipo = 'despesa' THEN valor_centavos ELSE 0 END) AS compras, "
    "SUM(CASE WHEN tipo = 'estorno' THEN valor_centavos ELSE 0 END) AS estornos, "
    "COUNT(*) AS lancamentos "
    "FROM lancamentos WHERE cartao_id = ? AND mes_fatura IS NOT NULL "
    "GROUP BY mes_fatura",
    variables: [Variable.withInt(cartaoId)],
    readsFrom: {attachedDatabase.lancamentos},
  ).watch().map(
    (linhas) => [
      for (final linha in linhas)
        (
          mes: linha.read<String>('mes_fatura'),
          compras: linha.read<int>('compras'),
          estornos: linha.read<int>('estornos'),
          lancamentos: linha.read<int>('lancamentos'),
        ),
    ],
  );
}
