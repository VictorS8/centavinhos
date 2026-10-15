import 'package:material_ui/material_ui.dart';

import '../../data/daos/cadastro_bloqueado.dart';
import '../../domain/cadastros.dart';

/// Janela com uma pergunta e dois botões. Devolve se a pessoa confirmou.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String botao,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Text(mensagem),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(botao),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}

/// Janela que só informa, com o botão "Entendi".
Future<void> avisar(BuildContext context, {required String titulo, required String mensagem}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(mensagem),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Entendi')),
        ],
      ),
    );

/// Tira um cadastro da lista: exclui de vez se nunca foi usado ou arquiva se
/// já foi, sempre depois de confirmar. Se [motivoBloqueio] devolver um
/// motivo, só avisa e não faz nada. [extra] completa a mensagem da
/// confirmação, como o aviso das subcategorias.
Future<void> tirarCadastro(
  BuildContext context, {
  required Cadastro tipo,
  required String nome,
  required bool emUso,
  required Future<void> Function() excluir,
  required Future<void> Function() arquivar,
  Future<String?> Function()? motivoBloqueio,
  String? extra,
}) async {
  final g = tipo.genero;
  final verbo = emUso ? 'arquivar' : 'excluir';
  final tituloBloqueio = 'Não é possível $verbo "$nome"';

  final motivo = await motivoBloqueio?.call();
  if (!context.mounted) return;
  if (motivo != null) {
    await avisar(context, titulo: tituloBloqueio, mensagem: motivo);
    return;
  }

  final este = '${g('Esta', 'Este')} ${tipo.nome}';
  final mensagem = emUso
      ? '$este já foi ${g('usada', 'usado')}, então não pode ser ${g('apagada', 'apagado')}. '
            '${g('Arquivada', 'Arquivado')}, ${g('ela', 'ele')} some das listas e dos '
            'formulários, mas continua nos lançamentos antigos.'
      : '$este nunca foi ${g('usada', 'usado')} e será ${g('apagada', 'apagado')} de vez.';
  final confirmado = await confirmar(
    context,
    titulo: '${emUso ? 'Arquivar' : 'Excluir'} "$nome"?',
    mensagem: [mensagem, ?extra].join(' '),
    botao: emUso ? 'Arquivar' : 'Excluir',
  );
  if (!confirmado || !context.mounted) return;

  final mensageiro = ScaffoldMessenger.of(context);
  try {
    await (emUso ? arquivar() : excluir());
  } on CadastroBloqueado catch (bloqueio) {
    if (context.mounted) await avisar(context, titulo: tituloBloqueio, mensagem: bloqueio.motivo);
    return;
  }
  final feito = emUso ? g('arquivada', 'arquivado') : g('excluída', 'excluído');
  mensageiro.showSnackBar(SnackBar(content: Text('${tipo.nomeMaiusculo} "$nome" $feito.')));
}

/// Desarquiva um cadastro. Se [motivoBloqueio] devolver um motivo, só avisa.
Future<void> desarquivarCadastro(
  BuildContext context, {
  required Cadastro tipo,
  required String nome,
  required Future<void> Function() desarquivar,
  Future<String?> Function()? motivoBloqueio,
}) async {
  final titulo = 'Não é possível desarquivar "$nome"';
  final motivo = await motivoBloqueio?.call();
  if (!context.mounted) return;
  if (motivo != null) {
    await avisar(context, titulo: titulo, mensagem: motivo);
    return;
  }
  final mensageiro = ScaffoldMessenger.of(context);
  try {
    await desarquivar();
  } on CadastroBloqueado catch (bloqueio) {
    if (context.mounted) await avisar(context, titulo: titulo, mensagem: bloqueio.motivo);
    return;
  }
  final feito = tipo.genero('desarquivada', 'desarquivado');
  mensageiro.showSnackBar(SnackBar(content: Text('${tipo.nomeMaiusculo} "$nome" $feito.')));
}
