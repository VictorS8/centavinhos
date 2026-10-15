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
