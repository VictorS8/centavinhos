import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../hoje_provider.dart';
import '../widgets/tela_em_construcao.dart';

class TelaMes extends ConsumerWidget {
  const TelaMes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mes = DateFormat('MMMM yyyy', 'pt_BR').format(ref.watch(hojeProvider));
    return TelaEmConstrucao(
      titulo: '${mes[0].toUpperCase()}${mes.substring(1)}',
      descricao: 'Totais de gastos, saldo de hoje e previsto e a lista de lançamentos do mês.',
      etapa: 4,
    );
  }
}

class TelaFiltros extends StatelessWidget {
  const TelaFiltros({super.key});

  @override
  Widget build(BuildContext context) => const TelaEmConstrucao(
    titulo: 'Filtros',
    descricao: 'Criar e editar filtros salvos, com prévia do resultado no mês.',
    etapa: 8,
  );
}

class TelaCartoes extends StatelessWidget {
  const TelaCartoes({super.key});

  @override
  Widget build(BuildContext context) => const TelaEmConstrucao(
    titulo: 'Cartões',
    descricao: 'Cartões com fechamento, vencimento e conta de pagamento, e as faturas por mês.',
    etapa: 2,
  );
}

class TelaCadastros extends StatelessWidget {
  const TelaCadastros({super.key});

  @override
  Widget build(BuildContext context) => const TelaEmConstrucao(
    titulo: 'Cadastros',
    descricao: 'Contas com saldo inicial, categorias com subcategorias e tags.',
    etapa: 2,
  );
}
