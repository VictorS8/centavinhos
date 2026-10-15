import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conexao.dart';
import 'configuracoes.dart';
import 'daos/cartoes_dao.dart';
import 'daos/categorias_dao.dart';
import 'daos/contas_dao.dart';
import 'daos/tags_dao.dart';
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

/// Contas, arquivadas ou não, com o uso de cada uma.
final contasProvider = StreamProvider<List<ContaComUso>>(
  (ref) => ref.watch(bancoProvider).contasDao.observar(),
);

/// Cartões, arquivados ou não, com o uso de cada um.
final cartoesProvider = StreamProvider<List<CartaoComUso>>(
  (ref) => ref.watch(bancoProvider).cartoesDao.observar(),
);

/// Categorias e subcategorias, arquivadas ou não, com o uso de cada uma.
final categoriasProvider = StreamProvider<List<CategoriaComUso>>(
  (ref) => ref.watch(bancoProvider).categoriasDao.observar(),
);

/// Tags, arquivadas ou não, com quantos lançamentos usam cada uma.
final tagsProvider = StreamProvider<List<TagComUso>>(
  (ref) => ref.watch(bancoProvider).tagsDao.observar(),
);
