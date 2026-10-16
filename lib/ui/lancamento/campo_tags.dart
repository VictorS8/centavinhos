import 'package:material_ui/material_ui.dart';

import '../../domain/cadastros.dart';
import '../../domain/sugestoes.dart';
import 'campo_com_sugestoes.dart';

/// Tags do lançamento: um campo com sugestões das tags ativas e, embaixo, as
/// escolhidas como etiquetas removíveis. Enter com um nome que não está nas
/// sugestões adiciona uma tag nova, criada ao salvar.
class CampoTags extends StatefulWidget {
  const CampoTags({
    super.key,
    required this.ativas,
    required this.todas,
    required this.escolhidas,
    required this.aoMudar,
    required this.aoEnviar,
  });

  /// Nomes das tags ativas, as que aparecem nas sugestões.
  final List<String> ativas;

  /// Nomes de todas as tags, arquivadas também, para uma tag digitada usar
  /// o nome como ele já está cadastrado.
  final List<String> todas;
  final List<String> escolhidas;
  final ValueChanged<List<String>> aoMudar;

  /// Enter com o campo vazio.
  final VoidCallback aoEnviar;

  @override
  State<CampoTags> createState() => _CampoTagsState();
}

class _CampoTagsState extends State<CampoTags> {
  final _texto = TextEditingController();
  final _foco = FocusNode();

  bool _jaEscolhida(String nome) =>
      widget.escolhidas.any((t) => chaveDoNome(t) == chaveDoNome(nome));

  void _adicionar(String nome) {
    final limpo = limparNomeTag(nome);
    if (limpo.isEmpty || _jaEscolhida(limpo)) return;
    final cadastrada = widget.todas.where((t) => chaveDoNome(t) == chaveDoNome(limpo)).firstOrNull;
    widget.aoMudar([...widget.escolhidas, cadastrada ?? limpo]);
  }

  void _enviar() {
    if (limparNomeTag(_texto.text).isEmpty) return widget.aoEnviar();
    _adicionar(_texto.text);
    _texto.clear();
  }

  @override
  void dispose() {
    _texto.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoComSugestoes<String>(
          controle: _texto,
          foco: _foco,
          rotulo: 'Tags',
          textoApoio: 'Enter adiciona; uma tag nova é criada ao salvar',
          sugestoes: (texto) => filtrarPorTexto(
            limparNomeTag(texto),
            widget.ativas.where((t) => !_jaEscolhida(t)),
            (t) => t,
          ),
          textoDa: (t) => t,
          aoEscolher: _adicionar,
          limparAoEscolher: true,
          aoEnviar: _enviar,
        ),
        if (widget.escolhidas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in widget.escolhidas)
                  ExcludeFocus(
                    child: InputChip(
                      label: Text(tag),
                      deleteButtonTooltipMessage: 'Tirar $tag',
                      onDeleted: () => widget.aoMudar([
                        for (final t in widget.escolhidas)
                          if (t != tag) t,
                      ]),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
