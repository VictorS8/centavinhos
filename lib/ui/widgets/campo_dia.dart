import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Campo de um dia do mês, de 1 a 31, como o fechamento e o vencimento de
/// um cartão. Aceita só números, no máximo dois.
class CampoDia extends StatelessWidget {
  const CampoDia({
    super.key,
    required this.controle,
    required this.rotulo,
    this.onSubmitted,
  });

  final TextEditingController controle;
  final String rotulo;

  /// Enter no campo.
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: TextField(
        controller: controle,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: '1 a 31',
          border: const OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      ),
    );
  }
}
