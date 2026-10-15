import 'package:material_ui/material_ui.dart';

/// Tipo da conta: Carteira ou Banco ('carteira' ou 'banco').
class SeletorTipoConta extends StatelessWidget {
  const SeletorTipoConta({super.key, required this.tipo, required this.onChanged});

  final String tipo;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'carteira', label: Text('Carteira')),
        ButtonSegment(value: 'banco', label: Text('Banco')),
      ],
      selected: {tipo},
      showSelectedIcon: false,
      onSelectionChanged: (selecao) => onChanged(selecao.single),
    );
  }
}
