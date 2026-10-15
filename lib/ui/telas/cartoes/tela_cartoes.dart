import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/daos/cartoes_dao.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../widgets/acoes_cadastro.dart';
import '../../widgets/lista_cadastro.dart';
import 'janela_cartao.dart';

/// Cartões à esquerda e o cartão escolhido à direita, com fechamento,
/// vencimento, conta de pagamento e, a partir da etapa 5, as faturas.
class TelaCartoes extends ConsumerStatefulWidget {
  const TelaCartoes({super.key});

  @override
  ConsumerState<TelaCartoes> createState() => _TelaCartoesState();
}

class _TelaCartoesState extends ConsumerState<TelaCartoes> {
  int? _escolhido;
  var _mostrarArquivados = false;

  Future<void> _novoCartao() async {
    final id = await abrirJanelaCartao(context);
    if (id != null && mounted) setState(() => _escolhido = id);
  }

  @override
  Widget build(BuildContext context) {
    final cartoes = ref.watch(cartoesProvider).value ?? const [];
    final contas = ref.watch(contasProvider).value ?? const [];
    final visiveis = [
      for (final item in cartoes)
        if (_mostrarArquivados || item.cartao.arquivado == 0) item,
    ];
    final atual =
        visiveis.where((c) => c.cartao.id == _escolhido).firstOrNull ?? visiveis.firstOrNull;
    final contaDoAtual = atual == null
        ? null
        : contas.where((c) => c.conta.id == atual.cartao.contaPagamentoId).firstOrNull?.conta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CabecalhoTela(
            titulo: 'Cartões',
            descricao: 'Cada fatura sai do saldo da conta de pagamento no dia do vencimento.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 340,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: _novoCartao,
                          icon: const Icon(Icons.add),
                          label: const Text('Novo cartão'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final item in visiveis)
                        _ItemCartao(
                          key: ValueKey(item.cartao.id),
                          cartao: item.cartao,
                          escolhido: item == atual,
                          aoEscolher: () => setState(() => _escolhido = item.cartao.id),
                        ),
                      const SizedBox(height: 8),
                      CaixaMostrarArquivados(
                        rotulo: Cadastro.cartao.mostrarArquivados,
                        valor: _mostrarArquivados,
                        onChanged: (valor) => setState(() => _mostrarArquivados = valor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: atual == null
                        ? const _SemCartoes()
                        : _DetalheCartao(item: atual, contaPagamento: contaDoAtual),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Fecha dia 5 · vence dia 12".
String _textoDias(Cartao cartao) =>
    'Fecha dia ${cartao.diaFechamento} · vence dia ${cartao.diaVencimento}';

class _ItemCartao extends StatelessWidget {
  const _ItemCartao({
    super.key,
    required this.cartao,
    required this.escolhido,
    required this.aoEscolher,
  });

  final Cartao cartao;
  final bool escolhido;
  final VoidCallback aoEscolher;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final arquivado = cartao.arquivado == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        type: escolhido ? MaterialType.canvas : MaterialType.transparency,
        color: escolhido ? cores.secondaryContainer : null,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: aoEscolher,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Opacity(
              opacity: arquivado ? 0.6 : 1,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: escolhido
                        ? cores.primaryContainer
                        : cores.surfaceContainerHighest,
                    foregroundColor: escolhido
                        ? cores.onPrimaryContainer
                        : cores.onSurfaceVariant,
                    child: const Icon(Icons.credit_card_outlined, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartao.nome,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          [_textoDias(cartao), if (arquivado) 'arquivado'].join(' · '),
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: cores.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quadro do cartão escolhido.
class _DetalheCartao extends ConsumerWidget {
  const _DetalheCartao({required this.item, required this.contaPagamento});

  final CartaoComUso item;
  final Conta? contaPagamento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final (:cartao, :emUso) = item;
    final arquivado = cartao.arquivado == 1;
    final dao = ref.read(bancoProvider).cartoesDao;

    return _Quadro(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  arquivado ? '${cartao.nome} (arquivado)' : cartao.nome,
                  style: tema.textTheme.headlineSmall,
                ),
              ),
              if (arquivado)
                FilledButton.tonalIcon(
                  onPressed: () => desarquivarCadastro(
                    context,
                    tipo: Cadastro.cartao,
                    nome: cartao.nome,
                    motivoBloqueio: () => dao.motivoParaNaoDesarquivar(cartao.id),
                    desarquivar: () => dao.desarquivar(cartao.id),
                  ),
                  icon: const Icon(Icons.unarchive_outlined),
                  label: const Text('Desarquivar'),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: () => abrirJanelaCartao(context, cartao: cartao),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar cartão'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => tirarCadastro(
                    context,
                    tipo: Cadastro.cartao,
                    nome: cartao.nome,
                    emUso: emUso,
                    excluir: () => dao.excluir(cartao.id),
                    arquivar: () => dao.arquivar(cartao.id),
                  ),
                  icon: Icon(emUso ? Icons.archive_outlined : Icons.delete_outline),
                  label: Text(emUso ? 'Arquivar' : 'Excluir'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Informacao('Fechamento', 'Dia ${cartao.diaFechamento}')),
              const SizedBox(width: 12),
              Expanded(child: _Informacao('Vencimento', 'Dia ${cartao.diaVencimento}')),
              const SizedBox(width: 12),
              Expanded(
                child: _Informacao('Conta de pagamento', contaPagamento?.nome ?? '—'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Faturas',
            style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ListaCadastro(
            linhas: const [],
            textoVazio: 'As faturas de cada mês, com o total e o "Ajustar pagamento", '
                'chegam na etapa 5.',
          ),
          if (arquivado) ...[
            const SizedBox(height: 16),
            Text(
              'Cartão arquivado: ele não aparece nos lançamentos novos, mas continua '
              'nos antigos.',
              style: tema.textTheme.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  const _Informacao(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fundo branco com contorno, como o quadro do cartão na imagem de
/// referência.
class _Quadro extends StatelessWidget {
  const _Quadro({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.surface,
        border: Border.all(color: cores.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

class _SemCartoes extends StatelessWidget {
  const _SemCartoes();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return _Quadro(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nenhum cartão cadastrado', style: tema.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Use "Novo cartão" para cadastrar o primeiro, com o fechamento, o '
            'vencimento e a conta que paga a fatura.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
