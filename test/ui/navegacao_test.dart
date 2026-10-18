import 'package:centavinhos/ui/hoje_provider.dart';
import 'package:centavinhos/ui/navegacao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relógio de mentira, para virar o dia nos testes.
final _relogio = NotifierProvider<_Relogio, DateTime>(_Relogio.new);

class _Relogio extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(2026, 10, 30, 23, 50);

  void mudar(DateTime agora) => state = agora;
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [hojeProvider.overrideWith((ref) => ref.watch(_relogio))],
    );
    // Mantém o mês escolhido vivo, como a tela do mês faz.
    container.listen(mesSelecionadoProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  DateTime mes() => container.read(mesSelecionadoProvider);
  void virar(DateTime agora) => container.read(_relogio.notifier).mudar(agora);

  test('começa no mês de hoje e as setas andam um mês', () {
    expect(mes(), DateTime(2026, 10));
    container.read(mesSelecionadoProvider.notifier).proximo();
    container.read(mesSelecionadoProvider.notifier).proximo();
    container.read(mesSelecionadoProvider.notifier).proximo();
    expect(mes(), DateTime(2027, 1));
    container.read(mesSelecionadoProvider.notifier).anterior();
    expect(mes(), DateTime(2026, 12));
  });

  test('virada do dia no mesmo mês não muda nada', () {
    virar(DateTime(2026, 10, 31, 0, 0, 1));
    expect(mes(), DateTime(2026, 10));
  });

  test('na virada do mês, quem estava no mês atual vai junto', () {
    virar(DateTime(2026, 11, 1, 0, 0, 1));
    expect(mes(), DateTime(2026, 11));
  });

  test('na virada do mês, quem tinha navegado fica onde está', () {
    container.read(mesSelecionadoProvider.notifier).anterior();
    virar(DateTime(2026, 11, 1, 0, 0, 1));
    expect(mes(), DateTime(2026, 9));
  });

  test('a tela aberta começa no mês e muda pelo provider', () {
    expect(container.read(telaAtualProvider), TelaPrincipal.mes);
    container.read(telaAtualProvider.notifier).ir(TelaPrincipal.cadastros);
    expect(container.read(telaAtualProvider), TelaPrincipal.cadastros);
  });
}
