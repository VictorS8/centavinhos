import 'package:material_ui/material_ui.dart';

/// Título e texto de apoio no topo de uma tela.
class CabecalhoTela extends StatelessWidget {
  const CabecalhoTela({super.key, required this.titulo, required this.descricao});

  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: tema.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          descricao,
          style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Lista de cadastros: um quadro com contorno e uma linha fina entre os
/// itens, como na tela de Cadastros.
class ListaCadastro extends StatelessWidget {
  const ListaCadastro({super.key, required this.linhas, this.textoVazio = 'Nada cadastrado.'});

  final List<Widget> linhas;
  final String textoVazio;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.surface,
        border: Border.all(color: cores.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: linhas.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  textoVazio,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cores.onSurfaceVariant,
                  ),
                ),
              )
            : Column(
                children: [
                  for (final (i, linha) in linhas.indexed) ...[
                    if (i > 0) Divider(height: 1, color: cores.outlineVariant),
                    linha,
                  ],
                ],
              ),
      ),
    );
  }
}

/// Uma linha da [ListaCadastro]: marca à esquerda, nome com um detalhe ao
/// lado, um valor opcional e os botões de ação à direita. Itens arquivados
/// aparecem esmaecidos.
class LinhaCadastro extends StatelessWidget {
  const LinhaCadastro({
    super.key,
    required this.marca,
    required this.nome,
    this.detalhe,
    this.valor,
    this.destaque = false,
    this.recuo = false,
    this.arquivado = false,
    this.acoes = const [],
  });

  final Widget marca;
  final String nome;
  final String? detalhe;

  /// Valor à direita, como o saldo inicial de uma conta.
  final String? valor;

  /// Nome em negrito, como nas categorias principais.
  final bool destaque;

  /// Linha de subcategoria, mais para dentro.
  final bool recuo;
  final bool arquivado;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final apoio = tema.colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.fromLTRB(recuo ? 56 : 16, 6, 12, 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Opacity(opacity: arquivado ? 0.5 : 1, child: marca),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: arquivado ? 0.6 : 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        nome,
                        overflow: TextOverflow.ellipsis,
                        style: destaque
                            ? textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                            : textos.bodyLarge,
                      ),
                    ),
                    if (detalhe != null) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 2,
                        child: Text(
                          detalhe!,
                          overflow: TextOverflow.ellipsis,
                          style: textos.bodyMedium?.copyWith(color: apoio),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (valor != null) ...[
              const SizedBox(width: 12),
              Opacity(
                opacity: arquivado ? 0.6 : 1,
                child: Text(valor!, style: textos.titleLarge?.copyWith(fontSize: 17)),
              ),
              const SizedBox(width: 12),
            ],
            ...acoes,
          ],
        ),
      ),
    );
  }
}

/// Marca redonda com a inicial do nome, como nas categorias.
class MarcaInicial extends StatelessWidget {
  const MarcaInicial(this.nome, {super.key});

  final String nome;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor: cores.secondaryContainer,
      foregroundColor: cores.onSecondaryContainer,
      child: Text(
        nome.isEmpty ? '?' : nome.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Marca redonda com um ícone, como nas contas.
class MarcaIcone extends StatelessWidget {
  const MarcaIcone(this.icone, {super.key});

  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor: cores.secondaryContainer,
      foregroundColor: cores.onSecondaryContainer,
      child: Icon(icone, size: 18),
    );
  }
}

/// Marcador pequeno das subcategorias.
class MarcaPonto extends StatelessWidget {
  const MarcaPonto({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.square(dimension: 5),
        ),
      ),
    );
  }
}

/// Os botões de ação de um cadastro: editar e excluir (nunca usado) ou
/// arquivar (usado); num item arquivado, só desarquivar.
List<Widget> botoesDeCadastro({
  required bool arquivado,
  required bool emUso,
  required VoidCallback aoEditar,
  required VoidCallback aoTirar,
  required VoidCallback aoDesarquivar,
  String rotuloEditar = 'Editar',
}) {
  if (arquivado) {
    return [
      IconButton(
        onPressed: aoDesarquivar,
        tooltip: 'Desarquivar',
        icon: const Icon(Icons.unarchive_outlined),
      ),
    ];
  }
  return [
    IconButton(
      onPressed: aoEditar,
      tooltip: rotuloEditar,
      icon: const Icon(Icons.edit_outlined),
    ),
    IconButton(
      onPressed: aoTirar,
      tooltip: emUso ? 'Arquivar' : 'Excluir',
      icon: Icon(emUso ? Icons.archive_outlined : Icons.delete_outline),
    ),
  ];
}

/// Caixa "Mostrar arquivadas" no pé das listas.
class CaixaMostrarArquivados extends StatelessWidget {
  const CaixaMostrarArquivados({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.onChanged,
  });

  final String rotulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => onChanged(!valor),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(value: valor, onChanged: (v) => onChanged(v ?? false)),
              Text(rotulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
