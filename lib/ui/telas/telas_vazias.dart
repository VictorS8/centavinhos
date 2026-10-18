import 'package:material_ui/material_ui.dart';

import '../widgets/tela_em_construcao.dart';

class TelaFiltros extends StatelessWidget {
  const TelaFiltros({super.key});

  @override
  Widget build(BuildContext context) => const TelaEmConstrucao(
    titulo: 'Filtros',
    descricao: 'Criar e editar filtros salvos, com prévia do resultado no mês.',
    etapa: 8,
  );
}
