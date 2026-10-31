// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/daos/cartoes_dao.dart';
import '../../data/daos/categorias_dao.dart';
import '../../data/daos/contas_dao.dart';
import '../../data/daos/lancamentos_dao.dart';
import '../../data/daos/tags_dao.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/cadastros.dart';
import '../../domain/datas.dart';
import '../../domain/exclusao.dart';
import '../../domain/fatura.dart';
import '../../domain/lancamento.dart';
import '../../domain/mes.dart';
import '../../domain/parcelas.dart';
import '../../domain/sugestoes.dart';
import '../hoje_provider.dart';
import '../navegacao.dart';
import '../widgets/campo_data.dart';
import '../widgets/campo_valor.dart';
import '../widgets/janela_formulario.dart';
import 'campo_com_sugestoes.dart';
import 'campo_tags.dart';
import 'excluir_lancamento.dart';
import 'menu_do_formulario.dart';
import 'seletor_categorias.dart';

/// O que a janela devolve ao salvar: o nome, o mês (AAAA-MM) em que o
/// lançamento conta (numa compra parcelada, o da 1ª parcela) e em quantas
/// parcelas uma compra nova foi dividida.
typedef LancamentoSalvo = ({String nome, String mes, int? parcelas});

/// Abre a janela de novo lançamento ou, com [lancamento], a de editar. Ao
/// salvar, mostra a confirmação no rodapé. Se o lançamento não aparece na
/// tela agora (outro mês ou outra tela), a mensagem tem "Ver", que leva à
/// tela do mês dele.
Future<void> abrirJanelaLancamento(
  BuildContext context, {
  LancamentoCompleto? lancamento,
}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final salvo = await showDialog<LancamentoSalvo>(
    context: context,
    builder: (_) => JanelaLancamento(lancamento: lancamento),
  );
  if (salvo == null) return;
  final mes = lerMesIso(salvo.mes);
  final naTela = container.read(telaAtualProvider) == TelaPrincipal.mes &&
      container.read(mesSelecionadoProvider) == mes;
  mensageiro
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          salvo.parcelas == null
              ? 'Lançamento "${salvo.nome}" salvo.'
              : 'Lançamento "${salvo.nome}" salvo em ${salvo.parcelas} parcelas.',
        ),
        // Com um botão, a mensagem ficaria até ser fechada.
        persist: false,
        action: naTela
            ? null
            : SnackBarAction(
                label: 'Ver',
                onPressed: () {
                  container.read(mesSelecionadoProvider.notifier).ir(mes);
                  container.read(telaAtualProvider.notifier).ir(TelaPrincipal.mes);
                },
              ),
      ),
    );
}

/// Lançamento rápido de ganho ou despesa. Na ordem do Tab: nome, valor,
/// recorrência, parcelas (só na compra parcelada), categorias, conta ou
/// cartão, a chave Estorno (só no cartão), data e fatura (só no cartão);
/// tags e observação ficam recolhidas em "Mais detalhes".
class JanelaLancamento extends ConsumerStatefulWidget {
  const JanelaLancamento({super.key, this.lancamento});

  /// O lançamento a editar, ou nulo para um novo.
  final LancamentoCompleto? lancamento;

  @override
  ConsumerState<JanelaLancamento> createState() => _JanelaLancamentoState();
}

/// Uma categoria escolhida e o valor digitado para ela (zero é vazio). Com
/// uma categoria só, o valor dela é o total e este fica sem uso.
class _Parte {
  _Parte(this.id, [this.valor = 0]);

  final int id;
  int valor;
}

/// Recorrência: única ou parcelada (só no cartão). A mensal chega na
/// etapa 6.
const _unica = 'unica';
const _parcelada = 'parcelada';

class _JanelaLancamentoState extends ConsumerState<JanelaLancamento> {
  late final DateTime _hoje = () {
    final agora = ref.read(hojeProvider);
    return DateTime(agora.year, agora.month, agora.day);
  }();

  Lancamento? get _existente => widget.lancamento?.lancamento;

  /// Numa edição, a recorrência e o número de parcelas não mudam.
  bool get _editando => _existente != null;
  bool get _editandoParcela => _existente?.totalParcelas != null;

  /// 'ganho' ou 'despesa'. O estorno é uma despesa com a chave ligada.
  late var _tipo = _existente == null || _existente!.tipo == 'estorno'
      ? 'despesa'
      : _existente!.tipo;
  late var _estorno = _existente?.tipo == 'estorno';
  late var _recorrencia = _editandoParcela ? _parcelada : _unica;
  late final _parcelas = TextEditingController()..addListener(() => setState(() {}));
  late final _nome = TextEditingController(text: _existente?.descricao ?? '')
    ..addListener(() => setState(() {}));
  final _focoNome = FocusNode();
  late var _valor = _existente?.valorCentavos ?? 0;
  late var _partes = [
    for (final parte in widget.lancamento?.categorias ?? const <ParteCategoria>[])
      _Parte(parte.categoriaId, parte.valorCentavos),
  ];

  /// Muda quando as categorias são trocadas de uma vez, para os campos de
  /// valor recomeçarem vazios.
  var _geracao = 0;
  late int? _contaId = _existente?.contaId;
  late int? _cartaoId = _existente?.cartaoId;
  late DateTime? _data = _existente == null ? _hoje : lerDataIso(_existente!.dataLancamento);
  late var _faturaManual = _existente?.faturaManual == 1;
  late String? _mesFaturaManual = _faturaManual ? _existente?.mesFatura : null;
  late var _tags = [...?widget.lancamento?.tags];
  late final _observacao = TextEditingController(text: _existente?.observacao ?? '');
  late var _maisDetalhes = _tags.isNotEmpty || _observacao.text.isNotEmpty;
  var _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _focoNome.dispose();
    _parcelas.dispose();
    _observacao.dispose();
    super.dispose();
  }

  /// O estorno e a compra parcelada só podem ser no cartão.
  bool get _soCartao => _estorno || _recorrencia == _parcelada;

  /// Número de parcelas de uma compra parcelada nova (zero com o campo
  /// vazio), ou nulo se ela não é parcelada ou se é uma edição.
  int? get _parcelasNovas =>
      !_editando && _recorrencia == _parcelada ? int.tryParse(_parcelas.text) ?? 0 : null;

  /// O tipo gravado: o estorno é uma despesa com a chave ligada.
  String get _tipoGravado => _estorno ? 'estorno' : _tipo;

  // Leituras dos cadastros

  List<Conta> get _contas => [
    for (final (:conta, emUso: _) in ref.read(contasProvider).value ?? const <ContaComUso>[])
      conta,
  ];

  List<Cartao> get _cartoes => [
    for (final (:cartao, emUso: _) in ref.read(cartoesProvider).value ?? const <CartaoComUso>[])
      cartao,
  ];

  Cartao? get _cartao => _cartaoId == null
      ? null
      : _cartoes.where((c) => c.id == _cartaoId).firstOrNull;

  /// Nome de cada categoria como aparece no lançamento, pelo id.
  Map<int, String> _rotulos(List<CategoriaComUso> todas) {
    final porId = {for (final (:categoria, emUso: _) in todas) categoria.id: categoria};
    return {
      for (final (:categoria, emUso: _) in todas)
        categoria.id: rotuloCategoria(
          categoria.nome,
          principal: porId[categoria.categoriaPaiId]?.nome,
        ),
    };
  }

  /// Categorias ativas do tipo do lançamento: cada principal seguida das
  /// subcategorias dela.
  List<OpcaoCategoria> _opcoesCategoria(List<CategoriaComUso> todas, Map<int, String> rotulos) => [
    for (final grupo in CategoriaComSubcategorias.montar(todas))
      if (grupo.categoria.tipo == _tipo && grupo.categoria.arquivada == 0) ...[
        (id: grupo.categoria.id, rotulo: rotulos[grupo.categoria.id]!),
        for (final (:categoria, emUso: _) in grupo.subcategorias)
          if (categoria.arquivada == 0) (id: categoria.id, rotulo: rotulos[categoria.id]!),
      ],
  ];

  // Conta ou cartão. No menu, cada opção é "conta:ID" ou "cartao:ID".

  String? get _origem => _contaId != null
      ? 'conta:$_contaId'
      : _cartaoId != null
      ? 'cartao:$_cartaoId'
      : null;

  void _escolherOrigem(String chave) {
    final [tipo, id] = chave.split(':');
    setState(() {
      _contaId = tipo == 'conta' ? int.parse(id) : null;
      _cartaoId = tipo == 'cartao' ? int.parse(id) : null;
      // Estorno só no cartão.
      if (_contaId != null) _estorno = false;
    });
  }

  /// Contas ativas e, numa despesa, cartões ativos. Numa edição, a conta ou
  /// o cartão atual aparece mesmo arquivado. No estorno e na compra
  /// parcelada, só os cartões.
  List<DropdownMenuEntry<String>> _opcoesOrigem() => [
    for (final conta in _contas)
      if (!_soCartao && (conta.arquivada == 0 || conta.id == _existente?.contaId))
        DropdownMenuEntry(
          value: 'conta:${conta.id}',
          label: conta.nome,
          leadingIcon: Icon(
            conta.tipo == 'carteira'
                ? Icons.account_balance_wallet_outlined
                : Icons.account_balance_outlined,
          ),
        ),
    if (_tipo == 'despesa')
      for (final cartao in _cartoes)
        if (cartao.arquivado == 0 || cartao.id == _existente?.cartaoId)
          DropdownMenuEntry(
            value: 'cartao:${cartao.id}',
            label: 'Cartão ${cartao.nome}',
            leadingIcon: const Icon(Icons.credit_card),
          ),
  ];

  // Fatura

  /// Mês da fatura pela data e pelo cartão, no formato AAAA-MM. Na edição de
  /// uma parcela, o da parcela: o da compra mais os meses das anteriores.
  String? _mesCalculado(Cartao cartao) => _data == null
      ? null
      : mesIso(
          mesDaFaturaDaParcela(
            _data!,
            parcela: _existente?.parcelaAtual ?? 1,
            diaFechamento: cartao.diaFechamento,
            diaVencimento: cartao.diaVencimento,
          ),
        );

  String? _mesFatura(Cartao? cartao) =>
      cartao == null ? null : (_faturaManual ? _mesFaturaManual : _mesCalculado(cartao));

  /// Escolher o mês calculado volta ao cálculo automático; outro mês fica
  /// marcado como trocado à mão.
  void _escolherFatura(String mes, String? calculado) => setState(() {
    _faturaManual = mes != calculado;
    _mesFaturaManual = _faturaManual ? mes : null;
  });

  /// Do segundo mês antes ao terceiro depois do calculado, e o escolhido à
  /// mão se ficar fora dessa faixa.
  List<DropdownMenuEntry<String>> _opcoesFatura(String? calculado, String? escolhido) {
    final base = lerMesIso(calculado ?? escolhido ?? mesIso(_hoje));
    final meses = {
      for (var i = -2; i <= 3; i++) mesIso(DateTime(base.year, base.month + i)),
      ?escolhido,
    }.toList()..sort();
    return [
      for (final mes in meses) DropdownMenuEntry(value: mes, label: mesAnoBr(lerMesIso(mes))),
    ];
  }

  // Ações

  void _trocarTipo(String tipo) {
    final categorias = ref.read(categoriasProvider).value ?? const <CategoriaComUso>[];
    final doTipo = {
      for (final (:categoria, emUso: _) in categorias)
        if (categoria.tipo == tipo) categoria.id,
    };
    setState(() {
      _tipo = tipo;
      _partes = [for (final parte in _partes) if (doTipo.contains(parte.id)) parte];
      if (tipo == 'ganho') {
        _cartaoId = null;
        _estorno = false;
        _recorrencia = _unica;
      }
    });
  }

  /// A compra parcelada só pode ser no cartão: uma conta escolhida sai.
  void _escolherRecorrencia(String recorrencia) => setState(() {
    _recorrencia = recorrencia;
    if (recorrencia == _parcelada) _contaId = null;
  });

  /// O estorno é sempre único.
  void _mudarEstorno(bool estorno) => setState(() {
    _estorno = estorno;
    if (estorno) _recorrencia = _unica;
  });

  /// Nome conhecido: repete da última vez as categorias (com os valores
  /// vazios), a conta ou o cartão, a recorrência (com o número de parcelas)
  /// e as tags. O valor não é copiado. No estorno, os nomes vêm das
  /// despesas, e uma conta da última vez não troca o cartão.
  Future<void> _escolherNome(String nome) async {
    final dao = ref.read(bancoProvider).lancamentosDao;
    final preenchimento = await dao.ultimoComNome(nome, _tipo);
    if (preenchimento == null || !mounted) return;
    setState(() {
      _partes = [for (final id in preenchimento.categoriaIds) _Parte(id)];
      _geracao++;
      if (!_editando && !_estorno) {
        final parcelas = preenchimento.parcelas;
        _recorrencia = parcelas == null ? _unica : _parcelada;
        if (parcelas != null) _parcelas.text = '$parcelas';
      }
      final cartaoId = _tipo == 'despesa' ? preenchimento.cartaoId : null;
      if (!_soCartao) {
        _contaId = preenchimento.contaId;
        _cartaoId = cartaoId;
      } else if (cartaoId != null) {
        _contaId = null;
        _cartaoId = cartaoId;
      }
      _faturaManual = false;
      _mesFaturaManual = null;
      _tags = [...preenchimento.tags];
      if (_tags.isNotEmpty) _maisDetalhes = true;
    });
  }

  void _adicionarCategoria(OpcaoCategoria opcao) => setState(() {
    // A partir da segunda categoria, todos os valores começam vazios.
    if (_partes.length == 1) _partes.single.valor = 0;
    _partes = [..._partes, _Parte(opcao.id)];
  });

  void _tirarCategoria(int id) =>
      setState(() => _partes = [for (final parte in _partes) if (parte.id != id) parte]);

  void _mudarValorCategoria(int id, int valor) =>
      setState(() => _partes.firstWhere((parte) => parte.id == id).valor = valor);

  String? _motivo() => motivoLancamentoInvalido(
    tipo: _tipoGravado,
    nome: _nome.text,
    valorCentavos: _valor,
    valoresCategorias: [for (final parte in _partes) parte.valor],
    temOrigem: _origem != null,
    data: _data,
    parcelas: _parcelasNovas,
  );

  void _cancelar() => Navigator.pop(context);

  /// Exclui o lançamento em edição, com confirmação, e fecha a janela.
  Future<void> _excluir() async {
    final existente = _existente!;
    final excluiu = await excluirComConfirmacao(
      context,
      ref.read(bancoProvider),
      (transferencia: false, id: existente.id),
      nome: nomeComParcela(
        existente.descricao,
        parcelaAtual: existente.parcelaAtual,
        totalParcelas: existente.totalParcelas,
      ),
    );
    if (excluiu && mounted) Navigator.pop(context);
  }

  /// Salva o lançamento. Na edição de uma parcela, pergunta antes se a
  /// mudança vale só para ela, para ela e as próximas ou para todas.
  Future<void> _salvar() async {
    if (_motivo() != null || _salvando) return;
    final banco = ref.read(bancoProvider);
    var alcance = AlcanceExclusao.soEste;
    final existente = _existente;
    if (existente != null && _editandoParcela) {
      setState(() => _salvando = true);
      final escolhido = await perguntarAlcanceDaEdicao(
        context,
        banco,
        existente.id,
        nome: nomeComParcela(
          existente.descricao,
          parcelaAtual: existente.parcelaAtual,
          totalParcelas: existente.totalParcelas,
        ),
      );
      if (!mounted) return;
      if (escolhido == null) {
        setState(() => _salvando = false);
        return;
      }
      alcance = escolhido;
    }
    setState(() => _salvando = true);
    final cartao = _cartao;
    final dados = DadosLancamento(
      tipo: _tipoGravado,
      descricao: _nome.text,
      valorCentavos: _valor,
      data: _data!,
      contaId: _contaId,
      cartaoId: _cartaoId,
      mesFatura: _mesFatura(cartao),
      faturaManual: cartao != null && _faturaManual,
      parcelas: _parcelasNovas,
      categorias: _partes.length == 1
          ? [(categoriaId: _partes.single.id, valorCentavos: _valor)]
          : [for (final parte in _partes) (categoriaId: parte.id, valorCentavos: parte.valor)],
      tags: _tags,
      observacao: _observacao.text,
    );
    try {
      await banco.lancamentosDao.salvar(dados, id: existente?.id, alcance: alcance);
      if (!mounted) return;
      Navigator.pop<LancamentoSalvo>(context, (
        nome: limparNome(_nome.text),
        mes: mesReferencia(data: dados.data, mesFatura: dados.mesFatura),
        parcelas: dados.parcelas,
      ));
    } catch (erro) {
      if (!mounted) return;
      setState(() => _salvando = false);
      avisarErroAoSalvar(context, erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Refaz a tela quando os cadastros ou os nomes usados mudam.
    ref.watch(contasProvider);
    ref.watch(cartoesProvider);
    final categorias = ref.watch(categoriasProvider).value ?? const <CategoriaComUso>[];
    final tags = ref.watch(tagsProvider).value ?? const <TagComUso>[];
    final nomesUsados = ref.watch(nomesUsadosProvider(_tipo)).value ?? const <String>[];

    final tema = Theme.of(context);
    final rotulos = _rotulos(categorias);
    final cartao = _cartao;
    final mesCalculado = cartao == null ? null : _mesCalculado(cartao);
    final mesFatura = _mesFatura(cartao);
    final motivo = _motivo();

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(_existente == null ? 'Novo lançamento' : 'Editar lançamento')),
          ExcludeFocus(
            child: IconButton(
              onPressed: _cancelar,
              tooltip: 'Fechar',
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
      scrollable: true,
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'ganho',
                  label: const Text('Ganho'),
                  tooltip: _editandoParcela ? 'Compra parcelada é sempre despesa' : null,
                  enabled: !_editandoParcela,
                ),
                const ButtonSegment(value: 'despesa', label: Text('Despesa')),
                const ButtonSegment(
                  value: 'transferencia',
                  label: Text('Transferência'),
                  tooltip: 'Chega na etapa 7',
                  enabled: false,
                ),
              ],
              selected: {_tipo},
              expandedInsets: EdgeInsets.zero,
              onSelectionChanged: (selecao) => _trocarTipo(selecao.single),
            ),
            const SizedBox(height: 20),
            CampoComSugestoes<String>(
              controle: _nome,
              foco: _focoNome,
              rotulo: 'Nome',
              autofocus: true,
              sugestoes: (texto) => sugestoesDeNome(texto, nomesUsados),
              textoDa: (nome) => nome,
              aoEscolher: _escolherNome,
              aoEnviar: _salvar,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoValor(
                    rotulo: 'Valor',
                    valorInicial: _valor,
                    onChanged: (valor) => setState(() => _valor = valor),
                    onSubmitted: _salvar,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MenuDoFormulario<String>(
                    rotulo: 'Recorrência',
                    escolhida: _recorrencia,
                    // Numa edição, a recorrência não muda; o estorno é
                    // sempre único.
                    ativo: !_editando && !_estorno,
                    opcoes: [
                      const DropdownMenuEntry(value: _unica, label: 'Única'),
                      const DropdownMenuEntry(
                        value: 'mensal',
                        label: 'Mensal (chega na etapa 6)',
                        enabled: false,
                      ),
                      DropdownMenuEntry(
                        value: _parcelada,
                        label: _editandoParcela
                            ? 'Parcelada · ${_existente!.totalParcelas}x'
                            : 'Parcelada',
                        enabled: _tipo == 'despesa',
                      ),
                    ],
                    aoEscolher: _escolherRecorrencia,
                    aoEnviar: _salvar,
                    aoCancelar: _cancelar,
                  ),
                ),
              ],
            ),
            if (_parcelasNovas != null) ...[
              const SizedBox(height: 16),
              _CampoParcelas(
                controle: _parcelas,
                divisao: _parcelasNovas! >= minimoDeParcelas &&
                        _parcelasNovas! <= maximoDeParcelas &&
                        _valor >= _parcelasNovas!
                    ? textoDasParcelas(_valor, _parcelasNovas!)
                    : '',
                aoEnviar: _salvar,
              ),
            ],
            const SizedBox(height: 16),
            SeletorCategorias(
              opcoes: _opcoesCategoria(categorias, rotulos),
              escolhidas: [
                for (final parte in _partes)
                  (id: parte.id, rotulo: rotulos[parte.id] ?? '', valor: parte.valor),
              ],
              total: _valor,
              geracao: _geracao,
              aoAdicionar: _adicionarCategoria,
              aoTirar: _tirarCategoria,
              aoMudarValor: _mudarValorCategoria,
              aoEnviar: _salvar,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MenuDoFormulario<String>(
                    rotulo: _tipo == 'ganho'
                        ? 'Conta'
                        : _soCartao
                        ? 'Cartão'
                        : 'Conta ou cartão',
                    escolhida: _origem,
                    opcoes: _opcoesOrigem(),
                    aoEscolher: _escolherOrigem,
                    aoEnviar: _salvar,
                    aoCancelar: _cancelar,
                  ),
                ),
                // Estorno só numa despesa no cartão, e nunca numa parcela.
                if (_tipo == 'despesa' && _cartaoId != null && !_editandoParcela) ...[
                  const SizedBox(width: 16),
                  _ChaveEstorno(valor: _estorno, aoMudar: _mudarEstorno),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoData(
                    rotulo: 'Data',
                    hoje: _hoje,
                    valorInicial: _data,
                    onChanged: (data) => setState(() => _data = data),
                    onSubmitted: _salvar,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: cartao == null
                      ? const SizedBox.shrink()
                      : MenuDoFormulario<String>(
                          rotulo: 'Fatura',
                          escolhida: mesFatura,
                          opcoes: _opcoesFatura(mesCalculado, mesFatura),
                          textoApoio: _faturaManual
                              ? 'Trocada à mão; não muda com a data'
                              : _parcelasNovas != null
                              ? '1ª parcela; as outras vêm depois'
                              : 'Calculada pela data; pode trocar',
                          aoEscolher: (mes) => _escolherFatura(mes, mesCalculado),
                          aoEnviar: _salvar,
                          aoCancelar: _cancelar,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _maisDetalhes = !_maisDetalhes),
                icon: Icon(_maisDetalhes ? Icons.expand_less : Icons.expand_more),
                label: const Text('Mais detalhes: tags e observação'),
              ),
            ),
            if (_maisDetalhes) ...[
              const SizedBox(height: 8),
              CampoTags(
                ativas: [
                  for (final (:tag, lancamentos: _) in tags)
                    if (tag.arquivada == 0) tag.nome,
                ],
                todas: [for (final (:tag, lancamentos: _) in tags) tag.nome],
                escolhidas: _tags,
                aoMudar: (escolhidas) => setState(() => _tags = escolhidas),
                aoEnviar: _salvar,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _observacao,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                  border: OutlineInputBorder(),
                ),
                onEditingComplete: () {},
                onSubmitted: (_) => _salvar(),
              ),
            ],
            if (motivo != null) ...[
              const SizedBox(height: 16),
              Text(
                motivo,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            if (_existente != null)
              TextButton(
                onPressed: _salvando ? null : _excluir,
                style: TextButton.styleFrom(foregroundColor: tema.colorScheme.error),
                child: const Text('Excluir'),
              ),
            const Spacer(),
            TextButton(onPressed: _cancelar, child: const Text('Cancelar')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: motivo == null && !_salvando ? _salvar : null,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Número de parcelas de uma compra parcelada nova, de 2 a 48, com a
/// divisão ao lado ("3x de R$ 100,00").
class _CampoParcelas extends StatelessWidget {
  const _CampoParcelas({required this.controle, required this.divisao, required this.aoEnviar});

  final TextEditingController controle;

  /// Vazia enquanto o número ou o valor não dão uma divisão válida.
  final String divisao;
  final VoidCallback aoEnviar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: TextField(
            controller: controle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: const InputDecoration(
              labelText: 'Parcelas',
              hintText: '2 a 48',
              border: OutlineInputBorder(),
            ),
            // O Enter salva sem tirar o foco do campo.
            onEditingComplete: () {},
            onSubmitted: (_) => aoEnviar(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            divisao,
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Chave "Estorno", ao lado de "Conta ou cartão": marca uma compra
/// cancelada ou devolvida, que abate da fatura. Espaço e Enter ligam e
/// desligam: é o único campo em que o Enter não salva o lançamento.
class _ChaveEstorno extends StatefulWidget {
  const _ChaveEstorno({required this.valor, required this.aoMudar});

  final bool valor;
  final ValueChanged<bool> aoMudar;

  @override
  State<_ChaveEstorno> createState() => _ChaveEstornoState();
}

class _ChaveEstornoState extends State<_ChaveEstorno> {
  late final _foco = FocusNode(
    onKeyEvent: (_, evento) {
      if (evento is KeyDownEvent &&
          (evento.logicalKey == LogicalKeyboardKey.enter ||
              evento.logicalKey == LogicalKeyboardKey.numpadEnter)) {
        widget.aoMudar(!widget.valor);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => widget.aoMudar(!widget.valor),
            child: Text('Estorno', style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          Switch(value: widget.valor, focusNode: _foco, onChanged: widget.aoMudar),
        ],
      ),
    );
  }
}
