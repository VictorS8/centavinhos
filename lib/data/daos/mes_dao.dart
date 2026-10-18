import 'package:drift/drift.dart';

import '../../domain/datas.dart';
import '../../domain/fatura.dart';
import '../../domain/mes.dart';
import '../database.dart';

/// A lista da tela do mês.
class MesDao extends DatabaseAccessor<AppDatabase> {
  MesDao(super.attachedDatabase);

  /// Lançamentos e transferências do [mes] (AAAA-MM), já na ordem da lista.
  /// Lançamentos contam pelo `mes_referencia` (a fatura, no cartão);
  /// transferências, pela data. Atualiza sozinho quando algo muda.
  Stream<List<ItemDoMes>> observar(String mes) {
    final db = attachedDatabase;
    return customSelect(
      'SELECT l.id, l.tipo, l.descricao, l.valor_centavos, l.data_lancamento, '
      'l.mes_fatura, l.parcela_atual, l.total_parcelas, l.recorrencia_id, '
      'co.nome AS conta, ca.nome AS cartao, ca.dia_vencimento '
      'FROM lancamentos l '
      'LEFT JOIN contas co ON co.id = l.conta_id '
      'LEFT JOIN cartoes ca ON ca.id = l.cartao_id '
      'WHERE l.mes_referencia = ?',
      variables: [Variable.withString(mes)],
      // As categorias e as transferências são lidas em seguida, mas também
      // refazem a lista quando mudam.
      readsFrom: {
        db.lancamentos,
        db.lancamentoCategorias,
        db.categorias,
        db.contas,
        db.cartoes,
        db.transferencias,
      },
    ).watch().asyncMap((linhas) => _montar(mes, linhas));
  }

  Future<List<ItemDoMes>> _montar(String mes, List<QueryRow> linhas) async {
    final categorias = <int, List<CategoriaDoItem>>{};
    final linhasCategorias = await customSelect(
      'SELECT lc.lancamento_id, lc.valor_centavos, c.nome, p.nome AS principal '
      'FROM lancamento_categorias lc '
      'JOIN lancamentos l ON l.id = lc.lancamento_id '
      'JOIN categorias c ON c.id = lc.categoria_id '
      'LEFT JOIN categorias p ON p.id = c.categoria_pai_id '
      'WHERE l.mes_referencia = ? ORDER BY lc.rowid',
      variables: [Variable.withString(mes)],
    ).get();
    for (final linha in linhasCategorias) {
      final nome = linha.read<String>('nome');
      final principal = linha.read<String?>('principal');
      categorias.putIfAbsent(linha.read<int>('lancamento_id'), () => []).add((
        rotulo: principal == null ? nome : '$principal, $nome',
        principal: principal ?? nome,
        valorCentavos: linha.read<int>('valor_centavos'),
      ));
    }

    final lancamentos = [
      for (final linha in linhas)
        () {
          final id = linha.read<int>('id');
          final mesFatura = linha.read<String?>('mes_fatura');
          final diaVencimento = linha.read<int?>('dia_vencimento');
          return ItemDoMes(
            tipo: linha.read<String>('tipo'),
            id: id,
            descricao: linha.read<String>('descricao'),
            valorCentavos: linha.read<int>('valor_centavos'),
            data: lerDataIso(linha.read<String>('data_lancamento')),
            categorias: categorias[id] ?? const [],
            conta: linha.read<String?>('conta'),
            cartao: linha.read<String?>('cartao'),
            vencimento: mesFatura == null || diaVencimento == null
                ? null
                : vencimentoDaFatura(lerMesIso(mesFatura), diaVencimento: diaVencimento),
            parcelaAtual: linha.read<int?>('parcela_atual'),
            totalParcelas: linha.read<int?>('total_parcelas'),
            mensal: linha.read<int?>('recorrencia_id') != null,
          );
        }(),
    ];

    final transferencias = await customSelect(
      'SELECT t.id, t.valor_centavos, t.data, t.recorrencia_id, '
      'o.nome AS origem, d.nome AS destino '
      'FROM transferencias t '
      'JOIN contas o ON o.id = t.conta_origem_id '
      'JOIN contas d ON d.id = t.conta_destino_id '
      'WHERE substr(t.data, 1, 7) = ?',
      variables: [Variable.withString(mes)],
    ).get();

    return ordenarParaLista([
      ...lancamentos,
      for (final linha in transferencias)
        ItemDoMes(
          tipo: 'transferencia',
          id: linha.read<int>('id'),
          descricao: '',
          valorCentavos: linha.read<int>('valor_centavos'),
          data: lerDataIso(linha.read<String>('data')),
          conta: linha.read<String>('origem'),
          contaDestino: linha.read<String>('destino'),
          mensal: linha.read<int?>('recorrencia_id') != null,
        ),
    ]);
  }
}
