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
