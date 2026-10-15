import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/daos/contas_dao.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../../domain/datas.dart';
import '../../hoje_provider.dart';
import '../../widgets/campo_data.dart';
import '../../widgets/campo_valor.dart';
import '../../widgets/janela_formulario.dart';
import '../../widgets/seletor_tipo_conta.dart';

/// Abre a janela de nova conta ou, com [conta], a de editar.
Future<void> abrirJanelaConta(BuildContext context, {Conta? conta}) =>
    showDialog<void>(context: context, builder: (_) => JanelaConta(conta: conta));

/// Nome, tipo, saldo inicial e a data desse saldo, na ordem do Tab.
class JanelaConta extends ConsumerStatefulWidget {
  const JanelaConta({super.key, this.conta});

  final Conta? conta;

  @override
  ConsumerState<JanelaConta> createState() => _JanelaContaState();
}

class _JanelaContaState extends ConsumerState<JanelaConta> {
  late final DateTime _hoje = ref.read(hojeProvider);
  late final _nome = TextEditingController(text: widget.conta?.nome ?? '')
    ..addListener(() => setState(() {}));
  late var _tipo = widget.conta?.tipo ?? 'banco';
  late var _saldo = widget.conta?.saldoInicialCentavos ?? 0;
  late DateTime? _data = widget.conta == null
      ? DateTime(_hoje.year, _hoje.month, _hoje.day)
      : lerDataIso(widget.conta!.dataSaldoInicial);
  var _salvando = false;

  String? _motivo() {
    final existentes = <NomeExistente>[
      for (final item in ref.read(contasProvider).value ?? const <ContaComUso>[])
        if (item.conta.id != widget.conta?.id)
          (nome: item.conta.nome, arquivado: item.conta.arquivada == 1),
    ];
    return motivoNomeInvalido(_nome.text, Cadastro.conta, existentes: existentes) ??
        motivoDataSaldoInvalida(_data, hoje: _hoje);
  }

  Future<void> _salvar() async {
    if (_motivo() != null || _salvando) return;
    setState(() => _salvando = true);
    final dao = ref.read(bancoProvider).contasDao;
    try {
      final conta = widget.conta;
      if (conta == null) {
        await dao.criar(
          nome: _nome.text,
          tipo: _tipo,
          saldoInicialCentavos: _saldo,
          dataSaldoInicial: _data!,
        );
      } else {
        await dao.editar(
          conta.id,
          nome: _nome.text,
          tipo: _tipo,
          saldoInicialCentavos: _saldo,
          dataSaldoInicial: _data!,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisarErroAoSalvar(context, erro);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Refaz a conferência do nome quando a lista de contas muda.
    ref.watch(contasProvider);
    return JanelaFormulario(
      titulo: widget.conta == null ? 'Nova conta' : 'Editar conta',
      motivoBloqueio: _motivo(),
      salvando: _salvando,
      aoSalvar: _salvar,
      campos: [
        TextField(
          controller: _nome,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da conta',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _salvar(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: SeletorTipoConta(
            tipo: _tipo,
            onChanged: (tipo) => setState(() => _tipo = tipo),
          ),
        ),
        const SizedBox(height: 16),
        CampoValor(
          rotulo: 'Saldo inicial',
          valorInicial: _saldo,
          permiteNegativo: true,
          textoApoio: 'Aperte - para negativo',
          onChanged: (centavos) => setState(() => _saldo = centavos),
          onSubmitted: _salvar,
        ),
        const SizedBox(height: 16),
        CampoData(
          rotulo: 'Saldo em',
          hoje: _hoje,
          valorInicial: _data,
          ultimaData: _hoje,
          textoApoio: 'Lançamentos antes desta data não mudam o saldo.',
          onChanged: (data) => setState(() => _data = data),
          onSubmitted: _salvar,
        ),
      ],
    );
  }
}
