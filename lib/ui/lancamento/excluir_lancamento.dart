import 'package:material_ui/material_ui.dart';

import '../../data/daos/exclusao_dao.dart';
import '../../data/database.dart';
import '../../domain/exclusao.dart';

/// Quanto tempo o "Desfazer" fica no rodapé.
const tempoParaDesfazer = Duration(seconds: 6);

/// Pede confirmação e exclui o [alvo], chamado de [nome] nas mensagens.
/// Numa parcela ou num recorrente, pergunta "só este", "este e os próximos"
/// ou "todos". Depois mostra a mensagem com "Desfazer" no rodapé. Devolve
/// se excluiu.
Future<bool> excluirComConfirmacao(
  BuildContext context,
  AppDatabase banco,
  AlvoExclusao alvo, {
  required String nome,
}) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final dao = banco.exclusaoDao;
  final grupo = await dao.grupoDe(alvo);
  if (!context.mounted) return false;
  final alcance = await showDialog<AlcanceExclusao>(
    context: context,
    builder: (_) => DialogoExcluir(alvo: alvo, nome: nome, grupo: grupo),
  );
  if (alcance == null) return false;

  final Excluidos excluidos;
  try {
    excluidos = await dao.excluir(alvo, alcance);
  } catch (_) {
    mensageiro.showSnackBar(const SnackBar(content: Text('Não foi possível excluir.')));
    return false;
  }
  mensageiro
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(_mensagem(excluidos, nome)),
        duration: tempoParaDesfazer,
        // Com um botão, a mensagem ficaria até ser fechada.
        persist: false,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            try {
              await dao.restaurar(excluidos);
            } catch (_) {
              mensageiro.showSnackBar(
                const SnackBar(content: Text('Não foi possível desfazer a exclusão.')),
              );
            }
          },
        ),
      ),
    );
  return true;
}

/// "Lançamento "Padaria" excluído.", "3 lançamentos "Fone Bluetooth"
/// excluídos." ou "Transferência excluída.".
String _mensagem(Excluidos excluidos, String nome) {
  final quantidade = excluidos.quantidade;
  if (excluidos.transferencias.isNotEmpty) {
    return quantidade == 1 ? 'Transferência excluída.' : '$quantidade transferências excluídas.';
  }
  return quantidade == 1
      ? 'Lançamento "$nome" excluído.'
      : '$quantidade lançamentos "${excluidos.lancamentos.first.descricao}" excluídos.';
}

/// Confirmação de exclusão. Sozinho, só "Excluir" ou "Cancelar"; numa
/// parcela ou num recorrente, as três opções com quantos saem em cada uma.
/// Devolve o alcance escolhido, ou nulo se cancelou.
class DialogoExcluir extends StatelessWidget {
  const DialogoExcluir({super.key, required this.alvo, required this.nome, required this.grupo});

  final AlvoExclusao alvo;
  final String nome;
  final GrupoDoAlvo grupo;

  @override
  Widget build(BuildContext context) {
    final titulo = Text('Excluir "$nome"?');
    final cancelar = TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancelar'),
    );

    if (grupo.tipo == TipoDeGrupo.nenhum) {
      return AlertDialog(
        title: titulo,
        content: const Text('Dá para desfazer logo depois, pela mensagem no rodapé.'),
        actions: [
          cancelar,
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, AlcanceExclusao.soEste),
            child: const Text('Excluir'),
          ),
        ],
      );
    }

    final parcelas = grupo.tipo == TipoDeGrupo.parcelas;
    final explicacao = parcelas
        ? 'Esta compra foi parcelada em ${grupo.membros.length} vezes.'
        : alvo.transferencia
        ? 'Esta transferência se repete todo mês. Excluindo esta e as próximas, ou todas, '
              'ela deixa de se repetir.'
        : 'Este lançamento se repete todo mês. Excluindo este e os próximos, ou todos, '
              'ele deixa de se repetir.';

    String quantos(AlcanceExclusao alcance) {
      final n = idsAExcluir(id: alvo.id, grupo: grupo.membros, alcance: alcance).length;
      return parcelas ? (n == 1 ? '1 parcela' : '$n parcelas') : (n == 1 ? '1 mês' : '$n meses');
    }

    final opcoes = alvo.transferencia
        ? const {
            AlcanceExclusao.soEste: 'Só esta',
            AlcanceExclusao.esteEOsProximos: 'Esta e as próximas',
            AlcanceExclusao.todos: 'Todas',
          }
        : const {
            AlcanceExclusao.soEste: 'Só este',
            AlcanceExclusao.esteEOsProximos: 'Este e os próximos',
            AlcanceExclusao.todos: 'Todos',
          };

    return AlertDialog(
      title: titulo,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(explicacao),
            const SizedBox(height: 16),
            for (final MapEntry(key: alcance, value: rotulo) in opcoes.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OpcaoExclusao(
                  rotulo: rotulo,
                  detalhe: quantos(alcance),
                  autofocus: alcance == AlcanceExclusao.soEste,
                  aoEscolher: () => Navigator.pop(context, alcance),
                ),
              ),
          ],
        ),
      ),
      actions: [cancelar],
    );
  }
}

/// Uma opção da confirmação: o que excluir à esquerda e quantos à direita.
class _OpcaoExclusao extends StatelessWidget {
  const _OpcaoExclusao({
    required this.rotulo,
    required this.detalhe,
    required this.autofocus,
    required this.aoEscolher,
  });

  final String rotulo;
  final String detalhe;
  final bool autofocus;
  final VoidCallback aoEscolher;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return OutlinedButton(
      autofocus: autofocus,
      onPressed: aoEscolher,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(rotulo)),
          Text(
            detalhe,
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
