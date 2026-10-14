import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/dev/dados_exemplo.dart';
import '../../data/providers.dart';
import '../widgets/tela_em_construcao.dart';

class TelaAjustes extends StatelessWidget {
  const TelaAjustes({super.key});

  @override
  Widget build(BuildContext context) => const TelaEmConstrucao(
    titulo: 'Ajustes',
    descricao: 'Cor do tema, modo claro ou escuro, backup e restauração.',
    etapa: 10,
    extra: kDebugMode ? _SecaoDesenvolvimento() : null,
  );
}

/// Ferramentas que só existem no modo de desenvolvimento.
class _SecaoDesenvolvimento extends ConsumerWidget {
  const _SecaoDesenvolvimento();

  Future<void> _confirmarEExecutar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required Future<void> Function() acao,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
    if (confirmado == true) await acao();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final banco = ref.read(bancoProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Desenvolvimento', style: tema.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Só aparece no modo de desenvolvimento.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonal(
                onPressed: () => _confirmarEExecutar(
                  context,
                  titulo: 'Recriar dados de exemplo?',
                  mensagem: 'Todos os dados serão apagados e trocados pelos de exemplo.',
                  acao: () => gerarDadosExemplo(banco),
                ),
                child: const Text('Recriar dados de exemplo'),
              ),
              FilledButton.tonal(
                onPressed: () => _confirmarEExecutar(
                  context,
                  titulo: 'Apagar tudo?',
                  mensagem: 'Todos os dados serão apagados e o app volta para as boas-vindas.',
                  acao: banco.apagarTudo,
                ),
                child: const Text('Apagar tudo e voltar às boas-vindas'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
