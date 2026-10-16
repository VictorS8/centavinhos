import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'brand/centavinhos_logo.dart';
import 'lancamento/janela_lancamento.dart';
import 'telas/tela_ajustes.dart';
import 'telas/cadastros/tela_cadastros.dart';
import 'telas/cartoes/tela_cartoes.dart';
import 'telas/telas_vazias.dart';

/// Estrutura principal: barra lateral com o logo, o botão + e as telas.
class CascaPrincipal extends StatefulWidget {
  const CascaPrincipal({super.key});

  @override
  State<CascaPrincipal> createState() => _CascaPrincipalState();
}

class _CascaPrincipalState extends State<CascaPrincipal> {
  var _indice = 0;

  static const _telas = <Widget>[
    TelaMes(),
    TelaFiltros(),
    TelaCartoes(),
    TelaCadastros(),
    TelaAjustes(),
  ];

  Future<void> _novoLancamento() => abrirJanelaLancamento(context);

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): _novoLancamento,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _indice,
                onDestinationSelected: (i) => setState(() => _indice = i),
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Column(
                    children: [
                      const CentavinhosLogo(size: 40),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _novoLancamento,
                        tooltip: 'Novo lançamento (Ctrl+N)',
                        elevation: 0,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today),
                    label: Text('Mês'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.filter_list),
                    label: Text('Filtros'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.credit_card_outlined),
                    selectedIcon: Icon(Icons.credit_card),
                    label: Text('Cartões'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: Text('Cadastros'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Ajustes'),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cores.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _telas[_indice],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
