import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/database.dart';
import '../../data/dev/dados_exemplo.dart';
import '../../data/providers.dart';
import '../../domain/cadastros.dart';
import '../brand/centavinhos_logo.dart';
import '../hoje_provider.dart';
import '../widgets/campo_dia.dart';
import '../widgets/campo_valor.dart';
import '../widgets/seletor_tipo_conta.dart';

/// Primeira abertura: cadastra as contas com o saldo de hoje (ao menos uma)
/// e, se a pessoa quiser, os cartões.
class TelaBoasVindas extends ConsumerStatefulWidget {
  const TelaBoasVindas({super.key});

  @override
  ConsumerState<TelaBoasVindas> createState() => _TelaBoasVindasState();
}

class _ContaRascunho {
  _ContaRascunho(this.chave, {String nome = '', this.tipo = 'banco'})
    : nome = TextEditingController(text: nome);

  final int chave;
  final TextEditingController nome;
  String tipo;
  int saldoCentavos = 0;

  String get nomeLimpo => nome.text.trim();
}

class _CartaoRascunho {
  _CartaoRascunho(this.chave);

  final int chave;
  final nome = TextEditingController();
  final fechamento = TextEditingController();
  final vencimento = TextEditingController();
  int? chaveConta;

  int? get diaFechamento => lerDiaDoMes(fechamento.text);
  int? get diaVencimento => lerDiaDoMes(vencimento.text);
}

class _TelaBoasVindasState extends ConsumerState<TelaBoasVindas> {
  var _proximaChave = 0;
  late final List<_ContaRascunho> _contas = [
    _novaConta(nome: 'Carteira', tipo: 'carteira'),
  ];
  final List<_CartaoRascunho> _cartoes = [];
  var _salvando = false;

  _ContaRascunho _novaConta({String nome = '', String tipo = 'banco'}) {
    final conta = _ContaRascunho(_proximaChave++, nome: nome, tipo: tipo);
    conta.nome.addListener(_atualizar);
    return conta;
  }

  _CartaoRascunho _novoCartao() {
    final cartao = _CartaoRascunho(_proximaChave++);
    for (final campo in [cartao.nome, cartao.fechamento, cartao.vencimento]) {
      campo.addListener(_atualizar);
    }
    return cartao;
  }

  void _atualizar() => setState(() {});

  @override
  void dispose() {
    for (final conta in _contas) {
      conta.nome.dispose();
    }
    for (final cartao in _cartoes) {
      cartao.nome.dispose();
      cartao.fechamento.dispose();
      cartao.vencimento.dispose();
    }
    super.dispose();
  }

  List<_ContaRascunho> get _contasComNome =>
      _contas.where((c) => c.nomeLimpo.isNotEmpty).toList();

  /// Por que o botão "Começar" está travado, ou nulo se dá para salvar.
  String? get _motivoBloqueio {
    if (_contas.isEmpty) return 'Cadastre ao menos uma conta.';
    if (_contas.any((c) => c.nomeLimpo.isEmpty)) return 'Dê um nome a cada conta.';
    final nomes = _contas.map((c) => c.nomeLimpo.toLowerCase()).toSet();
    if (nomes.length != _contas.length) return 'Há duas contas com o mesmo nome.';
    for (final cartao in _cartoes) {
      if (cartao.nome.text.trim().isEmpty) return 'Dê um nome a cada cartão.';
      if (cartao.diaFechamento == null || cartao.diaVencimento == null) {
        return 'Fechamento e vencimento vão de 1 a 31.';
      }
      if (!_contas.any((c) => c.chave == cartao.chaveConta)) {
        return 'Escolha a conta que paga cada cartão.';
      }
    }
    return null;
  }

  Future<void> _comecar() async {
    setState(() => _salvando = true);
    try {
      await ref.read(bancoProvider).concluirBoasVindas(
        contas: [
          for (final conta in _contas)
            NovaConta(
              nome: conta.nomeLimpo,
              tipo: conta.tipo,
              saldoInicialCentavos: conta.saldoCentavos,
            ),
        ],
        cartoes: [
          for (final cartao in _cartoes)
            NovoCartao(
              nome: cartao.nome.text.trim(),
              diaFechamento: cartao.diaFechamento!,
              diaVencimento: cartao.diaVencimento!,
              indiceContaPagamento: _contas.indexWhere((c) => c.chave == cartao.chaveConta),
            ),
        ],
        hoje: ref.read(hojeProvider),
      );
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $erro')),
      );
    }
  }

  void _removerConta(_ContaRascunho conta) => setState(() {
    _contas.remove(conta);
    for (final cartao in _cartoes) {
      if (cartao.chaveConta == conta.chave) cartao.chaveConta = null;
    }
    conta.nome.dispose();
  });

  void _removerCartao(_CartaoRascunho cartao) => setState(() {
    _cartoes.remove(cartao);
    cartao.nome.dispose();
    cartao.fechamento.dispose();
    cartao.vencimento.dispose();
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textos = tema.textTheme;
    final apoio = textos.bodyLarge?.copyWith(color: tema.colorScheme.onSurfaceVariant);
    final motivo = _motivoBloqueio;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CentavinhosLogoHorizontal(height: 48, brightness: tema.brightness),
                const SizedBox(height: 32),
                Text('Boas-vindas ao Centavinhos', style: textos.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Para começar, cadastre as contas que você usa com o saldo de hoje. '
                  'Os cartões são opcionais e podem ser cadastrados depois.',
                  style: apoio,
                ),
                const SizedBox(height: 32),
                Text('Contas', style: textos.titleLarge),
                const SizedBox(height: 4),
                Text('Carteira e bancos. Ao menos uma.', style: apoio),
                const SizedBox(height: 16),
                for (final conta in _contas) ...[
                  _LinhaConta(
                    key: ValueKey(conta.chave),
                    conta: conta,
                    podeRemover: _contas.length > 1,
                    aoMudar: _atualizar,
                    aoRemover: () => _removerConta(conta),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _contas.add(_novaConta())),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar conta'),
                ),
                const SizedBox(height: 40),
                Text('Cartões', style: textos.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Opcional. Cada cartão é pago por uma das contas acima.',
                  style: apoio,
                ),
                const SizedBox(height: 16),
                for (final cartao in _cartoes) ...[
                  _LinhaCartao(
                    key: ValueKey(cartao.chave),
                    cartao: cartao,
                    contas: _contasComNome,
                    aoMudar: _atualizar,
                    aoRemover: () => _removerCartao(cartao),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _cartoes.add(_novoCartao())),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar cartão'),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    if (kDebugMode)
                      TextButton(
                        onPressed: _salvando
                            ? null
                            : () => gerarDadosExemplo(ref.read(bancoProvider)),
                        child: const Text('Preencher com dados de exemplo'),
                      ),
                    const Spacer(),
                    if (motivo != null) ...[
                      Flexible(
                        child: Text(
                          motivo,
                          textAlign: TextAlign.end,
                          style: textos.bodyMedium?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    FilledButton(
                      onPressed: motivo == null && !_salvando ? _comecar : null,
                      child: const Text('Começar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinhaConta extends StatelessWidget {
  const _LinhaConta({
    super.key,
    required this.conta,
    required this.podeRemover,
    required this.aoMudar,
    required this.aoRemover,
  });

  final _ContaRascunho conta;
  final bool podeRemover;
  final VoidCallback aoMudar;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: conta.nome,
            decoration: const InputDecoration(
              labelText: 'Nome da conta',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SeletorTipoConta(
            tipo: conta.tipo,
            onChanged: (tipo) {
              conta.tipo = tipo;
              aoMudar();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: CampoValor(
            rotulo: 'Saldo hoje',
            valorInicial: conta.saldoCentavos,
            permiteNegativo: true,
            textoApoio: 'Aperte - para negativo',
            onChanged: (centavos) {
              conta.saldoCentavos = centavos;
              aoMudar();
            },
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            onPressed: podeRemover ? aoRemover : null,
            tooltip: 'Remover conta',
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _LinhaCartao extends StatelessWidget {
  const _LinhaCartao({
    super.key,
    required this.cartao,
    required this.contas,
    required this.aoMudar,
    required this.aoRemover,
  });

  final _CartaoRascunho cartao;
  final List<_ContaRascunho> contas;
  final VoidCallback aoMudar;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    final contaEscolhida = contas.any((c) => c.chave == cartao.chaveConta)
        ? cartao.chaveConta
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: cartao.nome,
            decoration: const InputDecoration(
              labelText: 'Nome do cartão',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        CampoDia(controle: cartao.fechamento, rotulo: 'Fechamento'),
        const SizedBox(width: 12),
        CampoDia(controle: cartao.vencimento, rotulo: 'Vencimento'),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: DropdownMenu<int>(
            // Recria o menu quando as contas mudam de nome.
            key: ValueKey(contas.map((c) => '${c.chave}:${c.nomeLimpo}').join('|')),
            initialSelection: contaEscolhida,
            label: const Text('Pago pela conta'),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final conta in contas)
                DropdownMenuEntry(value: conta.chave, label: conta.nomeLimpo),
            ],
            onSelected: (chave) {
              cartao.chaveConta = chave;
              aoMudar();
            },
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            onPressed: aoRemover,
            tooltip: 'Remover cartão',
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
