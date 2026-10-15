import 'package:material_ui/material_ui.dart';

/// Janela de formulário dos cadastros: título, campos, o motivo de o Salvar
/// estar travado (como no "Começar" das boas-vindas) e os botões Cancelar e
/// Salvar. Esc cancela.
class JanelaFormulario extends StatelessWidget {
  const JanelaFormulario({
    super.key,
    required this.titulo,
    required this.campos,
    required this.motivoBloqueio,
    required this.salvando,
    required this.aoSalvar,
  });

  final String titulo;
  final List<Widget> campos;

  /// Por que o formulário não pode ser salvo, ou nulo se pode.
  final String? motivoBloqueio;
  final bool salvando;
  final VoidCallback aoSalvar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return AlertDialog(
      title: Text(titulo),
      scrollable: true,
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ...campos,
            if (motivoBloqueio != null) ...[
              const SizedBox(height: 16),
              Text(
                motivoBloqueio!,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: motivoBloqueio == null && !salvando ? aoSalvar : null,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Mostra um erro inesperado ao salvar, no rodapé.
void avisarErroAoSalvar(BuildContext context, Object erro) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Não foi possível salvar: $erro')),
  );
}
