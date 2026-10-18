import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/datas.dart';

/// A data de hoje. No app é o relógio do computador, lido de novo a cada
/// meia-noite, para o app aberto na virada do dia passar para o dia novo.
/// Nos testes é trocada por uma data fixa (12/10/2026, a dos exemplos do
/// escopo), para os resultados e as capturas de tela não mudarem com o
/// passar dos dias.
final hojeProvider = Provider<DateTime>((ref) {
  final agora = DateTime.now();
  // Um segundo de folga, para a leitura já cair no dia novo.
  final virada = Timer(ateAMeiaNoite(agora) + const Duration(seconds: 1), ref.invalidateSelf);
  ref.onDispose(virada.cancel);
  return agora;
});
