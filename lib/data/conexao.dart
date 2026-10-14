import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Nome do arquivo do banco, na pasta de suporte do app
/// (%APPDATA%\Centavinhos\Centavinhos no Windows).
const nomeArquivoBanco = 'centavinhos.sqlite';

Future<File> arquivoDoBanco() async {
  final pasta = await getApplicationSupportDirectory();
  return File(p.join(pasta.path, nomeArquivoBanco));
}

/// Conexão com o arquivo do banco, aberta em segundo plano.
QueryExecutor abrirConexao() => LazyDatabase(
  () async => NativeDatabase.createInBackground(await arquivoDoBanco()),
);
