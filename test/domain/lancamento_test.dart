import 'package:centavinhos/domain/lancamento.dart';
import 'package:centavinhos/domain/multicategoria.dart';
import 'package:centavinhos/domain/sugestoes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('multicategoria', () {
    test('contador com o que falta, como no escopo', () {
      final d = Distribuicao(total: 10000, valores: [8000, 0]);
      expect(d.distribuido, 8000);
      expect(d.falta, 2000);
      expect(d.fecha, isFalse);
      expect(d.texto, 'Distribuído R\$ 80,00 de R\$ 100,00, faltam R\$ 20,00');
    });

    test('soma que bate fecha a distribuição', () {
      final d = Distribuicao(total: 10000, valores: [8000, 2000]);
      expect(d.falta, 0);
      expect(d.fecha, isTrue);
      expect(d.texto, 'Distribuído R\$ 100,00 de R\$ 100,00');
    });

    test('passar do total mostra o que sobra', () {
      final d = Distribuicao(total: 10000, valores: [8000, 3050]);
      expect(d.falta, -1050);
      expect(d.fecha, isFalse);
      expect(d.texto, 'Distribuído R\$ 110,50 de R\$ 100,00, sobram R\$ 10,50');
    });

    test('categoria com valor vazio não fecha, mesmo com a soma certa', () {
      expect(Distribuicao(total: 10000, valores: [10000, 0]).fecha, isFalse);
      expect(Distribuicao(total: 0, valores: [0, 0]).fecha, isFalse);
    });

    test('sem limite de categorias', () {
      final valores = List.filled(12, 1000);
      expect(Distribuicao(total: 12000, valores: valores).fecha, isTrue);
    });
  });

  group('motivo para não salvar', () {
    String? motivo({
      String tipo = 'despesa',
      String nome = 'Mercado',
      int valor = 10000,
      List<int> categorias = const [0],
      bool temOrigem = true,
      DateTime? data,
      bool semData = false,
    }) => motivoLancamentoInvalido(
      tipo: tipo,
      nome: nome,
      valorCentavos: valor,
      valoresCategorias: categorias,
      temOrigem: temOrigem,
      data: semData ? null : (data ?? DateTime(2026, 10, 12)),
    );

    test('tudo certo', () {
      expect(motivo(), isNull);
      expect(motivo(categorias: [6000, 4000]), isNull);
    });

    test('cada campo obrigatório, na ordem do formulário', () {
      expect(motivo(nome: '   '), 'Dê um nome ao lançamento.');
      expect(motivo(valor: 0), 'Digite o valor.');
      expect(motivo(categorias: []), 'Escolha uma categoria.');
      expect(motivo(categorias: [6000, 0]), 'Distribua o valor entre as categorias.');
      expect(motivo(categorias: [6000, 3000]), 'Distribua o valor entre as categorias.');
      expect(motivo(temOrigem: false), 'Escolha a conta ou o cartão.');
      expect(motivo(tipo: 'ganho', temOrigem: false), 'Escolha a conta.');
      expect(motivo(semData: true), 'Data inválida. Use dd/mm ou dd/mm/aaaa.');
      expect(motivo(nome: '', valor: 0, categorias: []), 'Dê um nome ao lançamento.');
    });

    test('com uma categoria só, o valor dela é o total', () {
      expect(motivo(categorias: [0]), isNull);
    });

    test('data no futuro e no passado distante são aceitas', () {
      expect(motivo(data: DateTime(2027, 1, 30)), isNull);
      expect(motivo(data: DateTime(2020, 1, 1)), isNull);
    });
  });

  group('mês de referência', () {
    test('no cartão é o mês da fatura; nas contas, o da data', () {
      expect(mesReferencia(data: DateTime(2026, 10, 6), mesFatura: '2026-11'), '2026-11');
      expect(mesReferencia(data: DateTime(2026, 10, 6)), '2026-10');
    });
  });

  group('sugestões', () {
    const usados = ['Mercado Atacadão', 'Farmácia', 'mercado atacadão', 'Mercadinho', 'Padaria'];

    test('nome contém o texto, sem diferenciar maiúsculas nem acentos', () {
      expect(sugestoesDeNome('merc', usados), ['Mercado Atacadão', 'Mercadinho']);
      expect(sugestoesDeNome('FARMACIA', usados), ['Farmácia']);
      expect(sugestoesDeNome('atacadao', usados), ['Mercado Atacadão']);
      expect(sugestoesDeNome('dari', usados), ['Padaria']);
    });

    test('campo vazio não sugere nada', () {
      expect(sugestoesDeNome('', usados), isEmpty);
      expect(sugestoesDeNome('   ', usados), isEmpty);
    });

    test('do mais recente ao mais antigo, até 8', () {
      final muitos = [for (var i = 1; i <= 12; i++) 'Conta $i'];
      expect(sugestoesDeNome('conta', muitos), muitos.take(limiteSugestoesNome));
    });

    test('categoria principal e subcategoria aparecem na busca', () {
      final categorias = [
        rotuloCategoria('Casa'),
        rotuloCategoria('Aluguel', principal: 'Casa'),
        rotuloCategoria('Mercado', principal: 'Casa'),
        rotuloCategoria('Saúde'),
      ];
      expect(categorias[2], 'Casa, Mercado');
      expect(filtrarPorTexto('casa', categorias, (c) => c), [
        'Casa',
        'Casa, Aluguel',
        'Casa, Mercado',
      ]);
      expect(filtrarPorTexto('merc', categorias, (c) => c), ['Casa, Mercado']);
      expect(filtrarPorTexto('saude', categorias, (c) => c), ['Saúde']);
    });
  });
}
