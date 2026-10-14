import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conexao.dart';
import 'configuracoes.dart';
import 'database.dart';

/// O banco do app. Nos testes, é trocado por um banco em memória.
final bancoProvider = Provider<AppDatabase>((ref) {
  final banco = AppDatabase(abrirConexao());
  ref.onDispose(banco.close);
  return banco;
});

/// Todas as configurações, atualizadas na hora em que mudam.
final configuracoesProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(bancoProvider).observarConfiguracoes(),
);

/// Se a tela de boas-vindas já foi concluída.
final boasVindasConcluidaProvider = Provider<AsyncValue<bool>>(
  (ref) => ref
      .watch(configuracoesProvider)
      .whenData((c) => c[ChaveConfiguracao.boasVindasConcluida] == '1'),
);
