// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../../domain/fatura.dart';
import '../database.dart';
import 'cadastro_bloqueado.dart';

/// Um cartão e se ele já foi usado em algum lugar.
typedef CartaoComUso = ({Cartao cartao, bool emUso});

/// Um cartão está em uso quando aparece num lançamento ou num ajuste de
/// fatura.
const _emUso = '''
  EXISTS (SELECT 1 FROM lancamentos WHERE cartao_id = c.id)
  OR EXISTS (SELECT 1 FROM faturas WHERE cartao_id = c.id)
''';

/// Cartões: criar, editar, arquivar, desarquivar e excluir.
class CartoesDao extends DatabaseAccessor<AppDatabase> {
  CartoesDao(super.attachedDatabase);

  Cartoes get _cartoes => attachedDatabase.cartoes;

  /// Todos os cartões, os ativos primeiro, cada grupo em ordem de nome.
  Stream<List<CartaoComUso>> observar() => customSelect(
    'SELECT c.*, ($_emUso) AS em_uso FROM cartoes c',
    readsFrom: {_cartoes, attachedDatabase.lancamentos, attachedDatabase.faturas},
  ).watch().map((linhas) {
    final cartoes = [
      for (final linha in linhas)
        (cartao: _cartoes.map(linha.data), emUso: linha.read<bool>('em_uso')),
    ];
    return cartoes..sort(
      (a, b) => a.cartao.arquivado != b.cartao.arquivado
          ? a.cartao.arquivado.compareTo(b.cartao.arquivado)
          : chaveDoNome(a.cartao.nome).compareTo(chaveDoNome(b.cartao.nome)),
    );
  });

  Future<bool> emUso(int id) => customSelect(
    'SELECT ($_emUso) AS em_uso FROM cartoes c WHERE c.id = ?',
    variables: [Variable.withInt(id)],
  ).map((linha) => linha.read<bool>('em_uso')).getSingle();

  Future<int> criar({
    required String nome,
    required int diaFechamento,
    required int diaVencimento,
    required int contaPagamentoId,
  }) => into(_cartoes).insert(
    CartoesCompanion.insert(
      nome: limparNome(nome),
      diaFechamento: diaFechamento,
      diaVencimento: diaVencimento,
      contaPagamentoId: contaPagamentoId,
    ),
  );

  /// Grava o cartão e, se o fechamento ou o vencimento mudou, recalcula o
  /// mês da fatura dos lançamentos dele que não foram trocados à mão.
  /// Devolve quantos lançamentos mudaram de fatura.
  Future<int> editar(
    int id, {
    required String nome,
    required int diaFechamento,
    required int diaVencimento,
    required int contaPagamentoId,
  }) => transaction(() async {
    await (update(_cartoes)..where((c) => c.id.equals(id))).write(
      CartoesCompanion(
        nome: Value(limparNome(nome)),
        diaFechamento: Value(diaFechamento),
        diaVencimento: Value(diaVencimento),
        contaPagamentoId: Value(contaPagamentoId),
      ),
    );

    final lancamentos = attachedDatabase.lancamentos;
    final doCartao = await (select(lancamentos)..where((l) => l.cartaoId.equals(id))).get();
    var mudaram = 0;
    for (final lancamento in doCartao) {
      final novo = faturaRecalculada(
        data: lancamento.dataLancamento,
        mesAtual: lancamento.mesFatura ?? '',
        manual: lancamento.faturaManual == 1,
        parcela: lancamento.parcelaAtual,
        diaFechamento: diaFechamento,
        diaVencimento: diaVencimento,
      );
      if (novo == null) continue;
      await (update(lancamentos)..where((l) => l.id.equals(lancamento.id))).write(
        // No cartão, o mês de referência é o da fatura.
        LancamentosCompanion(mesFatura: Value(novo), mesReferencia: Value(novo)),
      );
      mudaram++;
    }
    return mudaram;
  });

  Future<void> arquivar(int id) => _marcarArquivado(id, 1);

  /// Por que o cartão não pode ser desarquivado, ou nulo se pode: a conta
  /// que paga o cartão precisa estar ativa.
  Future<String?> motivoParaNaoDesarquivar(int id) async {
    final contas = attachedDatabase.contas;
    final consulta = select(_cartoes).join([
      innerJoin(contas, contas.id.equalsExp(_cartoes.contaPagamentoId)),
    ])..where(_cartoes.id.equals(id));
    final conta = (await consulta.getSingle()).readTable(contas);
    if (conta.arquivada == 0) return null;
    return 'Desarquive antes a conta ${conta.nome}, que paga este cartão.';
  }

  Future<void> desarquivar(int id) => transaction(() async {
    final motivo = await motivoParaNaoDesarquivar(id);
    if (motivo != null) throw CadastroBloqueado(motivo);
    await _marcarArquivado(id, 0);
  });

  /// Apaga de vez um cartão que nunca foi usado.
  Future<void> excluir(int id) => transaction(() async {
    if (await emUso(id)) {
      throw const CadastroBloqueado('Este cartão já foi usado: ele só pode ser arquivado.');
    }
    await (delete(_cartoes)..where((c) => c.id.equals(id))).go();
  });

  Future<void> _marcarArquivado(int id, int valor) => (update(_cartoes)
        ..where((c) => c.id.equals(id)))
      .write(CartoesCompanion(arquivado: Value(valor)));
}
