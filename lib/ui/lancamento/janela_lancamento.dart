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
import '../../domain/fatura.dart';
import '../../domain/lancamento.dart';
import '../../domain/mes.dart';
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

/// O que a janela devolve ao salvar: o nome e o mês (AAAA-MM) em que o
/// lançamento conta.
typedef LancamentoSalvo = ({String nome, String mes});

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
        content: Text('Lançamento "${salvo.nome}" salvo.'),
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
/// recorrência, categorias, conta ou cartão, data e fatura (só no cartão);
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

/// Recorrência única, a única opção ativa por enquanto.
const _unica = 'unica';

class _JanelaLancamentoState extends ConsumerState<JanelaLancamento> {
  late final DateTime _hoje = () {
    final agora = ref.read(hojeProvider);
    return DateTime(agora.year, agora.month, agora.day);
  }();

  Lancamento? get _existente => widget.lancamento?.lancamento;

  late var _tipo = _existente?.tipo ?? 'despesa';
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
    _observacao.dispose();
    super.dispose();
  }

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
    });
  }

  /// Contas ativas e, numa despesa, cartões ativos. Numa edição, a conta ou
  /// o cartão atual aparece mesmo arquivado.
  List<DropdownMenuEntry<String>> _opcoesOrigem() => [
    for (final conta in _contas)
      if (conta.arquivada == 0 || conta.id == _existente?.contaId)
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

  /// Mês da fatura pela data e pelo cartão, no formato AAAA-MM.
  String? _mesCalculado(Cartao cartao) => _data == null
      ? null
      : mesIso(
          mesDaFatura(
            _data!,
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
      if (tipo == 'ganho') _cartaoId = null;
    });
  }

  /// Nome conhecido: repete da última vez as categorias (com os valores
  /// vazios), a conta ou o cartão e as tags. O valor não é copiado.
  Future<void> _escolherNome(String nome) async {
    final dao = ref.read(bancoProvider).lancamentosDao;
    final preenchimento = await dao.ultimoComNome(nome, _tipo);
    if (preenchimento == null || !mounted) return;
    setState(() {
      _partes = [for (final id in preenchimento.categoriaIds) _Parte(id)];
      _geracao++;
      _contaId = preenchimento.contaId;
      _cartaoId = _tipo == 'despesa' ? preenchimento.cartaoId : null;
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
    tipo: _tipo,
    nome: _nome.text,
    valorCentavos: _valor,
    valoresCategorias: [for (final parte in _partes) parte.valor],
    temOrigem: _origem != null,
    data: _data,
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

  Future<void> _salvar() async {
    if (_motivo() != null || _salvando) return;
    setState(() => _salvando = true);
    final cartao = _cartao;
    final dados = DadosLancamento(
      tipo: _tipo,
      descricao: _nome.text,
      valorCentavos: _valor,
      data: _data!,
      contaId: _contaId,
      cartaoId: _cartaoId,
      mesFatura: _mesFatura(cartao),
      faturaManual: cartao != null && _faturaManual,
      categorias: _partes.length == 1
          ? [(categoriaId: _partes.single.id, valorCentavos: _valor)]
          : [for (final parte in _partes) (categoriaId: parte.id, valorCentavos: parte.valor)],
      tags: _tags,
      observacao: _observacao.text,
    );
    try {
      await ref.read(bancoProvider).lancamentosDao.salvar(dados, id: _existente?.id);
      if (!mounted) return;
      Navigator.pop<LancamentoSalvo>(context, (
        nome: limparNome(_nome.text),
        mes: mesReferencia(data: dados.data, mesFatura: dados.mesFatura),
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
              segments: const [
                ButtonSegment(value: 'ganho', label: Text('Ganho')),
                ButtonSegment(value: 'despesa', label: Text('Despesa')),
                ButtonSegment(
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
                    escolhida: _unica,
                    opcoes: const [
                      DropdownMenuEntry(value: _unica, label: 'Única'),
                      DropdownMenuEntry(
                        value: 'mensal',
                        label: 'Mensal (chega na etapa 6)',
                        enabled: false,
                      ),
                      DropdownMenuEntry(
                        value: 'parcelada',
                        label: 'Parcelada (chega na etapa 5)',
                        enabled: false,
                      ),
                    ],
                    aoEscolher: (_) {},
                    aoEnviar: _salvar,
                    aoCancelar: _cancelar,
                  ),
                ),
              ],
            ),
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
            MenuDoFormulario<String>(
              rotulo: _tipo == 'ganho' ? 'Conta' : 'Conta ou cartão',
              escolhida: _origem,
              opcoes: _opcoesOrigem(),
              aoEscolher: _escolherOrigem,
              aoEnviar: _salvar,
              aoCancelar: _cancelar,
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
