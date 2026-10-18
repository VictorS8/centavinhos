import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../domain/datas.dart';
import '../../../domain/dinheiro.dart';
import '../../../domain/mes.dart';
import '../../lancamento/excluir_lancamento.dart';
import '../../lancamento/janela_lancamento.dart';
import '../../navegacao.dart';
import '../../widgets/lista_cadastro.dart';
import 'linha_lancamento.dart';

/// Tela inicial: o mês escolhido, o total de gastos sem filtro e a lista de
/// lançamentos. O filtro, o saldo e o PDF chegam nas etapas 7 a 9.
class TelaMes extends ConsumerStatefulWidget {
  const TelaMes({super.key});

  @override
  ConsumerState<TelaMes> createState() => _TelaMesState();
}

class _TelaMesState extends ConsumerState<TelaMes> {
  /// A última lista que chegou. Ao trocar de mês, ela continua na tela
  /// enquanto o banco busca a do mês novo, sem piscar o "Nenhum lançamento".
  List<ItemDoMes>? _ultimos;

  /// Ao trocar de mês, a lista volta ao topo, com os totais à vista.
  final _rolagem = ScrollController();

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _abrir(ItemDoMes item) async {
    switch (item.tipo) {
      case 'estorno':
        _avisar('Editar estornos chega na etapa 5.');
      case 'transferencia':
        _avisar('Editar transferências chega na etapa 7.');
      default:
        final completo = await ref.read(bancoProvider).lancamentosDao.carregar(item.id);
        if (mounted) await abrirJanelaLancamento(context, lancamento: completo);
    }
  }

  Future<void> _excluir(ItemDoMes item) => excluirComConfirmacao(context, ref.read(bancoProvider), (
    transferencia: item.transferencia,
    id: item.id,
  ), nome: item.nome);

  @override
  Widget build(BuildContext context) {
    ref.listen(mesSelecionadoProvider, (_, _) {
      if (_rolagem.hasClients) _rolagem.jumpTo(0);
    });
    final mes = ref.watch(mesSelecionadoProvider);
    final consulta = ref.watch(itensDoMesProvider(mesIso(mes)));
    if (consulta.hasValue) _ultimos = consulta.value;
    final itens = _ultimos;

    final tema = Theme.of(context);
    final secao = tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SeletorMes(mes: mes),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: _rolagem,
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Text('Gastos', style: secao),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CartaoTotal(
                        rotulo: 'Total do mês, sem filtro',
                        valor: itens == null ? null : totalDeGastos(itens),
                      ),
                    ),
                    // Os outros dois totais chegam com os filtros (etapa 8).
                    const SizedBox(width: 12),
                    const Spacer(),
                    const SizedBox(width: 12),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Lançamentos', style: secao),
                const SizedBox(height: 12),
                if (itens != null)
                  ListaCadastro(
                    textoVazio:
                        'Nenhum lançamento em ${nomeDoMes(mes).toLowerCase()}. '
                        'Aperte + ou Ctrl+N para lançar.',
                    linhas: [
                      for (final item in itens)
                        LinhaLancamento(
                          key: ValueKey('${item.tipo}-${item.id}'),
                          item: item,
                          aoAbrir: () => _abrir(item),
                          aoExcluir: () => _excluir(item),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "‹ Outubro 2026 ›": o mês escolhido, com as setas para o anterior e o
/// próximo.
class _SeletorMes extends ConsumerWidget {
  const _SeletorMes({required this.mes});

  final DateTime mes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escolha = ref.read(mesSelecionadoProvider.notifier);
    return Row(
      children: [
        IconButton(
          onPressed: escolha.anterior,
          tooltip: 'Mês anterior',
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 8),
        Text(mesEAno(mes), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 8),
        IconButton(
          onPressed: escolha.proximo,
          tooltip: 'Próximo mês',
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

/// Cartão preenchido de um total, com o rótulo em cima e o valor em Libron.
class _CartaoTotal extends StatelessWidget {
  const _CartaoTotal({required this.rotulo, required this.valor});

  final String rotulo;

  /// Nulo enquanto o banco não respondeu.
  final int? valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: tema.textTheme.bodyMedium?.copyWith(color: cores.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(
              valor == null ? '' : formatarCentavos(valor!),
              style: tema.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
