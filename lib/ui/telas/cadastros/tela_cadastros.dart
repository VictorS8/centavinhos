import 'package:material_ui/material_ui.dart';

import '../../widgets/lista_cadastro.dart';
import 'aba_categorias.dart';
import 'aba_contas.dart';
import 'aba_tags.dart';

/// Contas, categorias e tags, cada um numa aba.
class TelaCadastros extends StatelessWidget {
  const TelaCadastros({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            CabecalhoTela(
              titulo: 'Cadastros',
              descricao: 'Itens nunca usados podem ser excluídos. Os usados em lançamentos '
                  'são arquivados, para não quebrar relatórios antigos.',
            ),
            SizedBox(height: 16),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Contas'),
                Tab(text: 'Categorias'),
                Tab(text: 'Tags'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [AbaContas(), AbaCategorias(), AbaTags()]),
            ),
          ],
        ),
      ),
    );
  }
}
