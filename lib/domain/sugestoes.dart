/// Sugestões dos campos com busca: nome, categoria e tags.
library;

import 'cadastros.dart';

/// Os [itens] cujo texto contém o [digitado], sem diferenciar maiúsculas
/// nem acentos ("saude" acha "Saúde"), na ordem em que vieram. Com o campo
/// vazio, não há sugestões.
List<T> filtrarPorTexto<T>(
  String digitado,
  Iterable<T> itens,
  String Function(T item) texto, {
  int? limite,
}) {
  final chave = chaveDoNome(digitado);
  if (chave.isEmpty) return [];
  final achados = itens.where((item) => chaveDoNome(texto(item)).contains(chave));
  return (limite == null ? achados : achados.take(limite)).toList();
}

/// Quantas sugestões de nome aparecem de uma vez.
const limiteSugestoesNome = 8;

/// Sugestões para o campo Nome: os nomes já usados que contêm o [digitado].
/// [usados] vem do mais recente para o mais antigo; um nome escrito de
/// jeitos diferentes ("Mercado" e "mercado") aparece uma vez, como na vez
/// mais recente.
List<String> sugestoesDeNome(String digitado, Iterable<String> usados) {
  final vistos = <String>{};
  final unicos = usados.where((nome) => vistos.add(chaveDoNome(nome)));
  return filtrarPorTexto(digitado, unicos, (nome) => nome, limite: limiteSugestoesNome);
}

/// Nome de categoria como aparece no lançamento: "Casa" para a principal e
/// "Casa, Mercado" para a subcategoria.
String rotuloCategoria(String nome, {String? principal}) =>
    principal == null ? nome : '$principal, $nome';
