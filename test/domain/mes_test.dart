import 'package:centavinhos/domain/datas.dart';
import 'package:centavinhos/domain/mes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ItemDoMes item(
    String tipo,
    int valor, {
    int id = 1,
    DateTime? data,
    List<CategoriaDoItem> categorias = const [],
    String? conta,
    String? cartao,
    DateTime? vencimento,
    String? contaDestino,
    int? parcelaAtual,
    int? totalParcelas,
    String descricao = 'Mercado',
  }) => ItemDoMes(
    tipo: tipo,
    id: id,
    descricao: descricao,
    valorCentavos: valor,
    data: data ?? DateTime(2026, 10, 3),
    categorias: categorias,
    conta: conta,
    cartao: cartao,
    vencimento: vencimento,
    contaDestino: contaDestino,
    parcelaAtual: parcelaAtual,
    totalParcelas: totalParcelas,
  );

  const mercado = (rotulo: 'Casa, Mercado', principal: 'Casa', valorCentavos: 8000);
  const limpeza = (rotulo: 'Casa, Limpeza', principal: 'Casa', valorCentavos: 2000);

  group('totalDeGastos', () {
    test('soma as despesas, em conta e no cartão', () {
      expect(totalDeGastos([item('despesa', 1850), item('despesa', 41230)]), 43080);
    });

    test('estorno abate do total', () {
      expect(totalDeGastos([item('despesa', 13600), item('estorno', 3000)]), 10600);
    });

    test('ganhos e transferências ficam de fora', () {
      expect(
        totalDeGastos([item('despesa', 1000), item('ganho', 400000), item('transferencia', 50000)]),
        1000,
      );
    });

    test('mês vazio dá zero, e só estornos dão negativo', () {
      expect(totalDeGastos([]), 0);
      expect(totalDeGastos([item('estorno', 5000)]), -5000);
    });
  });

  group('como aparece na lista', () {
    test('nome com a parcela atual', () {
      expect(nomeComParcela('Fone'), 'Fone');
      expect(nomeComParcela('Fone', parcelaAtual: 2, totalParcelas: 3), 'Fone (2/3)');
      expect(
        item('despesa', 10000, parcelaAtual: 1, totalParcelas: 3, descricao: 'Fone').nome,
        'Fone (1/3)',
      );
    });

    test('transferência tem o nome gerado pelas contas', () {
      final transferencia = item('transferencia', 50000, conta: 'Nubank', contaDestino: 'Inter');
      expect(transferencia.nome, 'Transferência Nubank para Inter');
      expect(transferencia.detalhe, 'Nubank → Inter');
    });

    test('valor com sinal pelo tipo', () {
      expect(item('despesa', 1250).valorNaLista, 'R\$ 12,50');
      expect(item('ganho', 400000).valorNaLista, '+R\$ 4.000,00');
      expect(item('estorno', 5000).valorNaLista, '−R\$ 50,00');
      expect(item('transferencia', 50000).valorNaLista, 'R\$ 500,00');
    });

    test('detalhe com a primeira categoria e a conta ou o cartão com o vencimento', () {
      expect(
        item('despesa', 10000, categorias: [mercado], conta: 'Carteira').detalhe,
        'Casa, Mercado · Carteira',
      );
      expect(
        item(
          'despesa',
          10000,
          categorias: [mercado, limpeza],
          cartao: 'Nubank',
          vencimento: DateTime(2026, 10, 12),
        ).detalhe,
        'Casa, Mercado · Nubank, vence 12/10',
      );
    });

    test('inicial da categoria principal e categorias a mais', () {
      final dividido = item('despesa', 10000, categorias: [mercado, limpeza]);
      expect(dividido.inicial, 'C');
      expect(dividido.categoriasAMais, 1);
      expect(item('despesa', 10000, categorias: [mercado]).categoriasAMais, 0);
      expect(item('transferencia', 10000).categoriasAMais, 0);
    });
  });

  test('ordem da lista: mais recente primeiro, lançamentos antes das transferências', () {
    final ordenado = ordenarParaLista([
      item('despesa', 1, id: 1, data: DateTime(2026, 10, 1)),
      item('transferencia', 1, id: 9, data: DateTime(2026, 10, 9)),
      item('despesa', 1, id: 2, data: DateTime(2026, 10, 9)),
      item('despesa', 1, id: 3, data: DateTime(2026, 10, 9)),
      item('despesa', 1, id: 4, data: DateTime(2026, 9, 28)),
    ]);
    expect([for (final i in ordenado) '${i.tipo[0]}${i.id}'], ['d3', 'd2', 't9', 'd1', 'd4']);
  });

  group('datas da tela do mês', () {
    test('mês e ano, dia e mês e início do mês', () {
      expect(mesEAno(DateTime(2026, 10)), 'Outubro 2026');
      expect(nomeDoMes(DateTime(2026, 3)), 'Março');
      expect(diaMesBr(DateTime(2026, 9, 5)), '05/09');
      expect(inicioDoMes(DateTime(2026, 10, 12, 15, 30)), DateTime(2026, 10));
    });

    test('quanto falta até a meia-noite', () {
      expect(ateAMeiaNoite(DateTime(2026, 10, 12, 23, 59, 30)), const Duration(seconds: 30));
      expect(ateAMeiaNoite(DateTime(2026, 10, 12)), const Duration(days: 1));
      expect(ateAMeiaNoite(DateTime(2026, 12, 31, 18)), const Duration(hours: 6));
    });
  });
}
