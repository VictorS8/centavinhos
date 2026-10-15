import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/daos/cartoes_dao.dart';
import '../../../data/daos/contas_dao.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../widgets/campo_dia.dart';
import '../../widgets/janela_formulario.dart';

/// Abre a janela de novo cartão ou, com [cartao], a de editar. Devolve o id
/// do cartão salvo, ou nulo se a janela foi cancelada.
Future<int?> abrirJanelaCartao(BuildContext context, {Cartao? cartao}) =>
    showDialog<int>(context: context, builder: (_) => JanelaCartao(cartao: cartao));

/// Nome, fechamento, vencimento e conta de pagamento, na ordem do Tab.
class JanelaCartao extends ConsumerStatefulWidget {
  const JanelaCartao({super.key, this.cartao});

  final Cartao? cartao;

  @override
  ConsumerState<JanelaCartao> createState() => _JanelaCartaoState();
}

class _JanelaCartaoState extends ConsumerState<JanelaCartao> {
  late final _nome = TextEditingController(text: widget.cartao?.nome ?? '');
  late final _fechamento = TextEditingController(
    text: widget.cartao?.diaFechamento.toString() ?? '',
  );
  late final _vencimento = TextEditingController(
    text: widget.cartao?.diaVencimento.toString() ?? '',
  );
  late int? _contaId = widget.cartao?.contaPagamentoId;
  var _salvando = false;

  @override
  void initState() {
    super.initState();
    for (final campo in [_nome, _fechamento, _vencimento]) {
      campo.addListener(() => setState(() {}));
    }
  }

  /// Contas que podem pagar o cartão: as ativas e, numa edição, a atual.
  List<Conta> _contas() => [
    for (final (:conta, emUso: _) in ref.read(contasProvider).value ?? const <ContaComUso>[])
      if (conta.arquivada == 0 || conta.id == widget.cartao?.contaPagamentoId) conta,
  ];

  String? _motivo(List<Conta> contas) {
    final existentes = <NomeExistente>[
      for (final (:cartao, emUso: _) in ref.read(cartoesProvider).value ?? const <CartaoComUso>[])
        if (cartao.id != widget.cartao?.id)
          (nome: cartao.nome, arquivado: cartao.arquivado == 1),
    ];
    final nome = motivoNomeInvalido(_nome.text, Cadastro.cartao, existentes: existentes);
    if (nome != null) return nome;
    if (lerDiaDoMes(_fechamento.text) == null || lerDiaDoMes(_vencimento.text) == null) {
      return 'Fechamento e vencimento vão de 1 a 31.';
    }
    if (!contas.any((c) => c.id == _contaId)) return 'Escolha a conta que paga o cartão.';
    return null;
  }

  Future<void> _salvar() async {
    if (_motivo(_contas()) != null || _salvando) return;
    setState(() => _salvando = true);
    final dao = ref.read(bancoProvider).cartoesDao;
    final fechamento = lerDiaDoMes(_fechamento.text)!;
    final vencimento = lerDiaDoMes(_vencimento.text)!;
    try {
      final cartao = widget.cartao;
      final int id;
      if (cartao == null) {
        id = await dao.criar(
          nome: _nome.text,
          diaFechamento: fechamento,
          diaVencimento: vencimento,
          contaPagamentoId: _contaId!,
        );
      } else {
        id = cartao.id;
        await dao.editar(
          id,
          nome: _nome.text,
          diaFechamento: fechamento,
          diaVencimento: vencimento,
          contaPagamentoId: _contaId!,
        );
      }
      if (mounted) Navigator.pop(context, id);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisarErroAoSalvar(context, erro);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _fechamento.dispose();
    _vencimento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Refaz as conferências quando as contas ou os cartões mudam.
    ref.watch(contasProvider);
    ref.watch(cartoesProvider);
    final contas = _contas();

    return JanelaFormulario(
      titulo: widget.cartao == null ? 'Novo cartão' : 'Editar cartão',
      motivoBloqueio: _motivo(contas),
      salvando: _salvando,
      aoSalvar: _salvar,
      campos: [
        TextField(
          controller: _nome,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome do cartão',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _salvar(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CampoDia(controle: _fechamento, rotulo: 'Fechamento', onSubmitted: _salvar),
            const SizedBox(width: 12),
            CampoDia(controle: _vencimento, rotulo: 'Vencimento', onSubmitted: _salvar),
          ],
        ),
        const SizedBox(height: 16),
        DropdownMenu<int>(
          initialSelection: contas.any((c) => c.id == _contaId) ? _contaId : null,
          label: const Text('Pago pela conta'),
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: [
            for (final conta in contas) DropdownMenuEntry(value: conta.id, label: conta.nome),
          ],
          onSelected: (id) => setState(() => _contaId = id),
        ),
      ],
    );
  }
}
