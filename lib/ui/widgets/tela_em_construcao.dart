import 'package:material_ui/material_ui.dart';

/// Conteúdo provisório das telas que ainda não foram construídas.
class TelaEmConstrucao extends StatelessWidget {
  const TelaEmConstrucao({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.etapa,
    this.extra,
  });

  final String titulo;
  final String descricao;

  /// Etapa da ordem de construção em que a tela fica pronta.
  final int etapa;

  /// Conteúdo opcional abaixo do aviso.
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      children: [
        Text(titulo, style: tema.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          descricao,
          style: tema.textTheme.bodyLarge?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Esta tela chega na etapa $etapa.',
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        ?extra,
      ],
    );
  }
}
