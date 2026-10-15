import 'package:drift/drift.dart';

import '../../domain/cadastros.dart';
import '../../domain/datas.dart';
import '../database.dart';
import 'cadastro_bloqueado.dart';

/// Uma conta e se ela já foi usada em algum lugar.
typedef ContaComUso = ({Conta conta, bool emUso});

/// Uma conta está em uso quando aparece num lançamento, numa transferência,
/// num cartão (mesmo arquivado) ou num ajuste de fatura.
const _emUso = '''
  EXISTS (SELECT 1 FROM lancamentos WHERE conta_id = c.id)
  OR EXISTS (SELECT 1 FROM transferencias
             WHERE conta_origem_id = c.id OR conta_destino_id = c.id)
  OR EXISTS (SELECT 1 FROM cartoes WHERE conta_pagamento_id = c.id)
  OR EXISTS (SELECT 1 FROM faturas WHERE conta_pagamento_id = c.id)
''';

/// Carteira e bancos: criar, editar, arquivar, desarquivar e excluir.
class ContasDao extends DatabaseAccessor<AppDatabase> {
  ContasDao(super.attachedDatabase);

  Contas get _contas => attachedDatabase.contas;

  /// Todas as contas, as ativas primeiro, cada grupo em ordem de nome.
  Stream<List<ContaComUso>> observar() => customSelect(
    'SELECT c.*, ($_emUso) AS em_uso FROM contas c',
    readsFrom: {
      _contas,
      attachedDatabase.lancamentos,
      attachedDatabase.transferencias,
      attachedDatabase.cartoes,
      attachedDatabase.faturas,
    },
  ).watch().map((linhas) {
    final contas = [
      for (final linha in linhas)
        (conta: _contas.map(linha.data), emUso: linha.read<bool>('em_uso')),
    ];
    return contas..sort(
      (a, b) => a.conta.arquivada != b.conta.arquivada
          ? a.conta.arquivada.compareTo(b.conta.arquivada)
          : chaveDoNome(a.conta.nome).compareTo(chaveDoNome(b.conta.nome)),
    );
  });

  Future<bool> emUso(int id) => customSelect(
    'SELECT ($_emUso) AS em_uso FROM contas c WHERE c.id = ?',
    variables: [Variable.withInt(id)],
  ).map((linha) => linha.read<bool>('em_uso')).getSingle();

  Future<int> criar({
    required String nome,
    required String tipo,
    required int saldoInicialCentavos,
    required DateTime dataSaldoInicial,
  }) => into(_contas).insert(
    ContasCompanion.insert(
      nome: limparNome(nome),
      tipo: tipo,
      saldoInicialCentavos: Value(saldoInicialCentavos),
      dataSaldoInicial: dataIso(dataSaldoInicial),
    ),
  );

  Future<void> editar(
    int id, {
    required String nome,
    required String tipo,
    required int saldoInicialCentavos,
    required DateTime dataSaldoInicial,
  }) => (update(_contas)..where((c) => c.id.equals(id))).write(
    ContasCompanion(
      nome: Value(limparNome(nome)),
      tipo: Value(tipo),
      saldoInicialCentavos: Value(saldoInicialCentavos),
      dataSaldoInicial: Value(dataIso(dataSaldoInicial)),
    ),
  );

  /// Por que a conta não pode ser arquivada nem excluída, ou nulo se pode.
  Future<String?> motivoParaNaoTirar(int id) async {
    final ativas = await (select(_contas)..where((c) => c.arquivada.equals(0))).get();
    final cartoes = attachedDatabase.cartoes;
    final pagos = await (select(cartoes)
          ..where((c) => c.contaPagamentoId.equals(id) & c.arquivado.equals(0))
          ..orderBy([(c) => OrderingTerm(expression: c.id)]))
        .map((c) => c.nome)
        .get();
    return motivoParaNaoTirarConta(contasAtivas: ativas.length, cartoesQueElaPaga: pagos);
  }

  Future<void> arquivar(int id) => transaction(() async {
    final motivo = await motivoParaNaoTirar(id);
    if (motivo != null) throw CadastroBloqueado(motivo);
    await _marcarArquivada(id, 1);
  });

  Future<void> desarquivar(int id) => _marcarArquivada(id, 0);

  /// Apaga de vez uma conta que nunca foi usada.
  Future<void> excluir(int id) => transaction(() async {
    final motivo = await motivoParaNaoTirar(id);
    if (motivo != null) throw CadastroBloqueado(motivo);
    if (await emUso(id)) {
      throw const CadastroBloqueado('Esta conta já foi usada: ela só pode ser arquivada.');
    }
    await (delete(_contas)..where((c) => c.id.equals(id))).go();
  });

  Future<void> _marcarArquivada(int id, int valor) => (update(_contas)
        ..where((c) => c.id.equals(id)))
      .write(ContasCompanion(arquivada: Value(valor)));
}
