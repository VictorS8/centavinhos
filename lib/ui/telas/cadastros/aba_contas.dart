import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../domain/cadastros.dart';
import '../../../domain/datas.dart';
import '../../../domain/dinheiro.dart';
import '../../widgets/acoes_cadastro.dart';
import '../../widgets/lista_cadastro.dart';
import 'janela_conta.dart';

/// Carteira e bancos, com o saldo inicial e a data dele.
class AbaContas extends ConsumerStatefulWidget {
  const AbaContas({super.key});

  @override
  ConsumerState<AbaContas> createState() => _AbaContasState();
}

class _AbaContasState extends ConsumerState<AbaContas> {
  var _mostrarArquivadas = false;

  @override
  Widget build(BuildContext context) {
    final contas = ref.watch(contasProvider).value ?? const [];
    final dao = ref.read(bancoProvider).contasDao;

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      children: [
        Row(
          children: [
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () => abrirJanelaConta(context),
              icon: const Icon(Icons.add),
              label: const Text('Nova conta'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListaCadastro(
          textoVazio: 'Nenhuma conta.',
          linhas: [
            for (final (:conta, :emUso) in contas)
              if (_mostrarArquivadas || conta.arquivada == 0)
                LinhaCadastro(
                  key: ValueKey(conta.id),
                  marca: MarcaIcone(
                    conta.tipo == 'carteira'
                        ? Icons.account_balance_wallet_outlined
                        : Icons.account_balance_outlined,
                  ),
                  nome: conta.nome,
                  detalhe: [
                    conta.tipo == 'carteira' ? 'Carteira' : 'Banco',
                    'saldo inicial em ${dataBr(lerDataIso(conta.dataSaldoInicial))}',
                    if (conta.arquivada == 1) 'arquivada',
                  ].join(' · '),
                  valor: formatarCentavos(conta.saldoInicialCentavos),
                  arquivado: conta.arquivada == 1,
                  acoes: botoesDeCadastro(
                    arquivado: conta.arquivada == 1,
                    emUso: emUso,
                    aoEditar: () => abrirJanelaConta(context, conta: conta),
                    aoTirar: () => tirarCadastro(
                      context,
                      tipo: Cadastro.conta,
                      nome: conta.nome,
                      emUso: emUso,
                      motivoBloqueio: () => dao.motivoParaNaoTirar(conta.id),
                      excluir: () => dao.excluir(conta.id),
                      arquivar: () => dao.arquivar(conta.id),
                    ),
                    aoDesarquivar: () => desarquivarCadastro(
                      context,
                      tipo: Cadastro.conta,
                      nome: conta.nome,
                      desarquivar: () => dao.desarquivar(conta.id),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 12),
        CaixaMostrarArquivados(
          rotulo: Cadastro.conta.mostrarArquivados,
          valor: _mostrarArquivadas,
          onChanged: (valor) => setState(() => _mostrarArquivadas = valor),
        ),
      ],
    );
  }
}
