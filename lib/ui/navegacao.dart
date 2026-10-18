import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/datas.dart';
import 'hoje_provider.dart';

/// As telas da barra lateral, na ordem dela.
enum TelaPrincipal { mes, filtros, cartoes, cadastros, ajustes }

/// A tela aberta na barra lateral.
final telaAtualProvider = NotifierProvider<TelaAtual, TelaPrincipal>(TelaAtual.new);

class TelaAtual extends Notifier<TelaPrincipal> {
  @override
  TelaPrincipal build() => TelaPrincipal.mes;

  void ir(TelaPrincipal tela) => state = tela;
}

/// O mês da tela do mês (o primeiro dia dele). Começa no mês de hoje e não
/// muda ao trocar de tela. Na virada do mês, quem estava no mês atual passa
/// para o mês novo; quem tinha navegado para outro fica onde está.
final mesSelecionadoProvider = NotifierProvider<MesSelecionado, DateTime>(MesSelecionado.new);

class MesSelecionado extends Notifier<DateTime> {
  @override
  DateTime build() {
    ref.listen(hojeProvider, (antes, hoje) {
      if (antes != null && state == inicioDoMes(antes)) state = inicioDoMes(hoje);
    });
    return inicioDoMes(ref.read(hojeProvider));
  }

  void ir(DateTime mes) => state = inicioDoMes(mes);

  void anterior() => ir(DateTime(state.year, state.month - 1));

  void proximo() => ir(DateTime(state.year, state.month + 1));
}
