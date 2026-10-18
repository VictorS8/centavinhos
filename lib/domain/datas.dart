/// Datas no formato guardado no banco.
library;

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Dia no formato AAAA-MM-DD.
String dataIso(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-${_doisDigitos(data.month)}-'
    '${_doisDigitos(data.day)}';

/// Mês no formato AAAA-MM.
String mesIso(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-${_doisDigitos(data.month)}';

/// Dia no formato dd/mm/aaaa, como aparece na tela.
String dataBr(DateTime data) =>
    '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/'
    '${data.year.toString().padLeft(4, '0')}';

/// Lê um dia no formato AAAA-MM-DD, o guardado no banco.
DateTime lerDataIso(String texto) {
  final [ano, mes, dia] = texto.split('-').map(int.parse).toList();
  return DateTime(ano, mes, dia);
}

/// Lê um mês no formato AAAA-MM. Devolve o primeiro dia dele.
DateTime lerMesIso(String texto) {
  final [ano, mes] = texto.split('-').map(int.parse).toList();
  return DateTime(ano, mes);
}

const _nomesDosMeses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// Mês e ano como aparecem no campo Fatura, como "Novembro/2026".
String mesAnoBr(DateTime mes) => '${_nomesDosMeses[mes.month - 1]}/${mes.year}';

/// Último dia do [mes] de [ano] (28, 29, 30 ou 31).
int ultimoDiaDoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

/// O [dia] no [mes] de [ano] ou, se ele não existir naquele mês (31 em abril,
/// 30 em fevereiro), o último dia do mês. [mes] pode passar de 12.
DateTime diaNoMes(int ano, int mes, int dia) {
  final primeiro = DateTime(ano, mes);
  final ultimo = ultimoDiaDoMes(primeiro.year, primeiro.month);
  return DateTime(primeiro.year, primeiro.month, dia > ultimo ? ultimo : dia);
}

/// Nome do mês, como "Outubro".
String nomeDoMes(DateTime mes) => _nomesDosMeses[mes.month - 1];

/// Mês e ano no topo da tela do mês, como "Outubro 2026".
String mesEAno(DateTime mes) => '${nomeDoMes(mes)} ${mes.year}';

/// Dia e mês, como "28/09", na lista de lançamentos.
String diaMesBr(DateTime data) => '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}';

/// Primeiro dia do mês de [data].
DateTime inicioDoMes(DateTime data) => DateTime(data.year, data.month);

/// Quanto falta de [agora] até a meia-noite seguinte, quando "hoje" muda.
Duration ateAMeiaNoite(DateTime agora) =>
    DateTime(agora.year, agora.month, agora.day + 1).difference(agora);
