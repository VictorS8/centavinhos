import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A data de hoje. No app é o relógio do computador; nos testes é trocada por
/// uma data fixa (12/10/2026, a dos exemplos do escopo), para os resultados e
/// as capturas de tela não mudarem com o passar dos dias.
final hojeProvider = Provider<DateTime>((ref) => DateTime.now());
