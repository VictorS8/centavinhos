/// Regras dos cadastros: contas, cartões, categorias e tags.
library;

/// Os tipos de cadastro, com as palavras que as mensagens usam.
enum Cadastro {
  conta('conta', feminino: true),
  cartao('cartão', feminino: false),
  categoria('categoria', feminino: true),
  subcategoria('subcategoria', feminino: true),
  tag('tag', feminino: true);

  const Cadastro(this.nome, {required this.feminino});

  final String nome;
  final bool feminino;

  String get _um => feminino ? 'uma' : 'um';
  String get _ao => feminino ? 'à' : 'ao';
  String get _arquivado => feminino ? 'arquivada' : 'arquivado';
  String get _pronome => feminino ? 'a' : 'o';

  /// Rótulo da caixa que mostra os arquivados ("Mostrar arquivadas").
  String get mostrarArquivados => 'Mostrar ${_arquivado}s';

  /// O nome com a primeira letra maiúscula ("Conta", "Cartão").
  String get nomeMaiusculo => '${nome[0].toUpperCase()}${nome.substring(1)}';

  /// Escolhe a forma [feminina] ou [masculina] de uma palavra.
  String genero(String feminina, String masculina) => feminino ? feminina : masculina;
}

/// Nome sem espaços nas pontas e sem espaços repetidos no meio.
String limparNome(String nome) => nome.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Nome de tag: como [limparNome], sem o "#" das hashtags no começo.
String limparNomeTag(String nome) => limparNome(limparNome(nome).replaceFirst(RegExp(r'^#+'), ''));

const _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Forma usada para comparar nomes: sem maiúsculas e sem acentos.
/// "Saúde" e "saude" dão o mesmo resultado.
String chaveDoNome(String nome) => limparNome(nome)
    .toLowerCase()
    .split('')
    .map((letra) => _semAcento[letra] ?? letra)
    .join();

/// Um nome que já existe, para conferir repetição.
typedef NomeExistente = ({String nome, bool arquivado});

/// Por que [nome] não pode ser usado num cadastro do tipo [tipo], ou nulo
/// se pode. [existentes] são os outros itens do mesmo grupo (sem o próprio
/// item, quando é uma edição), incluindo os arquivados.
String? motivoNomeInvalido(
  String nome,
  Cadastro tipo, {
  required Iterable<NomeExistente> existentes,
}) {
  final limpo = tipo == Cadastro.tag ? limparNomeTag(nome) : limparNome(nome);
  if (limpo.isEmpty) return 'Dê um nome ${tipo._ao} ${tipo.nome}.';
  final chave = chaveDoNome(limpo);
  final igual = existentes.where((e) => chaveDoNome(e.nome) == chave).firstOrNull;
  if (igual == null) return null;
  if (igual.arquivado) {
    return 'Já existe ${tipo._um} ${tipo.nome} ${tipo._arquivado} com esse nome. '
        'Desarquive-${tipo._pronome} em "${tipo.mostrarArquivados}".';
  }
  return 'Já existe ${tipo._um} ${tipo.nome} com esse nome.';
}

/// Dia de fechamento ou vencimento digitado: de 1 a 31, ou nulo se inválido.
int? lerDiaDoMes(String texto) {
  final dia = int.tryParse(texto.trim());
  return dia != null && dia >= 1 && dia <= 31 ? dia : null;
}

/// Por que uma conta não pode ser arquivada nem excluída, ou nulo se pode.
///
/// [contasAtivas] conta todas as contas não arquivadas, incluindo ela.
/// [cartoesQueElaPaga] são os nomes dos cartões ativos pagos por ela.
String? motivoParaNaoTirarConta({
  required int contasAtivas,
  required List<String> cartoesQueElaPaga,
}) {
  if (cartoesQueElaPaga.isNotEmpty) {
    final nomes = cartoesQueElaPaga;
    if (nomes.length == 1) return 'Troque antes a conta que paga o cartão ${nomes.single}.';
    final lista = '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
    return 'Troque antes a conta que paga os cartões $lista.';
  }
  if (contasAtivas <= 1) return 'É preciso ter ao menos uma conta ativa.';
  return null;
}

/// Por que [data] não serve como data do saldo inicial, ou nulo se serve.
String? motivoDataSaldoInvalida(DateTime? data, {required DateTime hoje}) {
  if (data == null) return 'Data inválida. Use dd/mm ou dd/mm/aaaa.';
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  if (data.isAfter(dia)) return 'A data do saldo não pode ser depois de hoje.';
  return null;
}

/// "sem subcategorias", "1 subcategoria" ou "N subcategorias".
String textoSubcategorias(int quantidade) => switch (quantidade) {
  0 => 'sem subcategorias',
  1 => '1 subcategoria',
  _ => '$quantidade subcategorias',
};

/// "sem uso", "usada em 1 lançamento" ou "usada em N lançamentos".
String textoUsoTag(int lancamentos) => switch (lancamentos) {
  0 => 'sem uso',
  1 => 'usada em 1 lançamento',
  _ => 'usada em $lancamentos lançamentos',
};
