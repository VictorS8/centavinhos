import 'package:centavinhos/domain/cadastros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nomes', () {
    test('limpa espaços nas pontas e repetidos', () {
      expect(limparNome('  Conta   de  casa '), 'Conta de casa');
    });

    test('tag perde o # do começo', () {
      expect(limparNomeTag('#viagem'), 'viagem');
      expect(limparNomeTag('  ## trabalho '), 'trabalho');
      expect(limparNomeTag('c#'), 'c#');
    });

    test('comparação ignora maiúsculas e acentos', () {
      expect(chaveDoNome('Saúde'), chaveDoNome('saude'));
      expect(chaveDoNome('ALIMENTAÇÃO'), chaveDoNome('alimentacao'));
      expect(chaveDoNome(' Nubank '), chaveDoNome('nubank'));
      expect(chaveDoNome('Inter'), isNot(chaveDoNome('Nubank')));
    });
  });

  group('motivoNomeInvalido', () {
    const existentes = <NomeExistente>[
      (nome: 'Nubank', arquivado: false),
      (nome: 'Itaú', arquivado: true),
    ];

    String? motivo(String nome, Cadastro tipo) =>
        motivoNomeInvalido(nome, tipo, existentes: existentes);

    test('nome livre passa', () {
      expect(motivo('Inter', Cadastro.conta), isNull);
    });

    test('nome vazio', () {
      expect(motivo('   ', Cadastro.conta), 'Dê um nome à conta.');
      expect(motivo('', Cadastro.cartao), 'Dê um nome ao cartão.');
      expect(motivo('#', Cadastro.tag), 'Dê um nome à tag.');
    });

    test('repetido entre os ativos', () {
      expect(motivo('nubank', Cadastro.conta), 'Já existe uma conta com esse nome.');
      expect(motivo('NUBANK ', Cadastro.cartao), 'Já existe um cartão com esse nome.');
    });

    test('repetido com um arquivado sugere desarquivar', () {
      expect(
        motivo('itau', Cadastro.conta),
        'Já existe uma conta arquivada com esse nome. '
        'Desarquive-a em "Mostrar arquivadas".',
      );
      expect(
        motivo('Itaú', Cadastro.cartao),
        'Já existe um cartão arquivado com esse nome. '
        'Desarquive-o em "Mostrar arquivados".',
      );
    });

    test('tag compara sem o #', () {
      expect(
        motivoNomeInvalido('#Viagem', Cadastro.tag, existentes: [(nome: 'viagem', arquivado: false)]),
        'Já existe uma tag com esse nome.',
      );
    });
  });

  group('lerDiaDoMes', () {
    test('de 1 a 31', () {
      expect(lerDiaDoMes('1'), 1);
      expect(lerDiaDoMes('31'), 31);
      expect(lerDiaDoMes(' 5 '), 5);
    });

    test('fora da faixa ou vazio', () {
      expect(lerDiaDoMes('0'), isNull);
      expect(lerDiaDoMes('32'), isNull);
      expect(lerDiaDoMes(''), isNull);
      expect(lerDiaDoMes('a'), isNull);
    });
  });

  group('motivoParaNaoTirarConta', () {
    test('conta livre pode sair', () {
      expect(motivoParaNaoTirarConta(contasAtivas: 2, cartoesQueElaPaga: []), isNull);
    });

    test('última conta ativa fica', () {
      expect(
        motivoParaNaoTirarConta(contasAtivas: 1, cartoesQueElaPaga: []),
        'É preciso ter ao menos uma conta ativa.',
      );
    });

    test('conta que paga cartão ativo fica', () {
      expect(
        motivoParaNaoTirarConta(contasAtivas: 3, cartoesQueElaPaga: ['Nubank']),
        'Troque antes a conta que paga o cartão Nubank.',
      );
      expect(
        motivoParaNaoTirarConta(contasAtivas: 3, cartoesQueElaPaga: ['Nubank', 'Inter', 'C6']),
        'Troque antes a conta que paga os cartões Nubank, Inter e C6.',
      );
    });
  });

  group('motivoDataSaldoInvalida', () {
    final hoje = DateTime(2026, 10, 12, 15, 30);

    test('hoje e dias anteriores servem', () {
      expect(motivoDataSaldoInvalida(DateTime(2026, 10, 12), hoje: hoje), isNull);
      expect(motivoDataSaldoInvalida(DateTime(2026, 10, 1), hoje: hoje), isNull);
      expect(motivoDataSaldoInvalida(DateTime(2025, 1, 1), hoje: hoje), isNull);
    });

    test('futuro não serve', () {
      expect(
        motivoDataSaldoInvalida(DateTime(2026, 10, 13), hoje: hoje),
        'A data do saldo não pode ser depois de hoje.',
      );
    });

    test('data inválida', () {
      expect(
        motivoDataSaldoInvalida(null, hoje: hoje),
        'Data inválida. Use dd/mm ou dd/mm/aaaa.',
      );
    });
  });

  group('textos de contagem', () {
    test('subcategorias', () {
      expect(textoSubcategorias(0), 'sem subcategorias');
      expect(textoSubcategorias(1), '1 subcategoria');
      expect(textoSubcategorias(5), '5 subcategorias');
    });

    test('uso de tags', () {
      expect(textoUsoTag(0), 'sem uso');
      expect(textoUsoTag(1), 'usada em 1 lançamento');
      expect(textoUsoTag(12), 'usada em 12 lançamentos');
    });
  });
}
