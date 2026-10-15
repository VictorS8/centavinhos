/// Datas digitadas nos campos de data.
library;

final _formato = RegExp(r'^(\d{1,2})/(\d{1,2})(?:/(\d{4}))?$');

/// Lê uma data digitada como "15/10" (completa com o ano de [hoje]) ou
/// "15/10/2026". Devolve nulo se o texto não for uma data que existe, como
/// "31/02" ou "10/13".
DateTime? lerDataDigitada(String texto, {required DateTime hoje}) {
  final partes = _formato.firstMatch(texto.replaceAll(' ', ''));
  if (partes == null) return null;
  final dia = int.parse(partes[1]!);
  final mes = int.parse(partes[2]!);
  final ano = partes[3] == null ? hoje.year : int.parse(partes[3]!);
  if (mes < 1 || mes > 12 || dia < 1) return null;
  final data = DateTime(ano, mes, dia);
  // DateTime passa dias a mais para o mês seguinte (31/02 vira 03/03).
  if (data.month != mes || data.day != dia) return null;
  return data;
}
