import 'package:centavinhos/domain/valor_caixa_eletronico.dart';
import 'package:flutter_test/flutter_test.dart';

ValorCaixaEletronico digitarTudo(
  String teclas, {
  bool permiteNegativo = false,
}) {
  var valor = ValorCaixaEletronico(permiteNegativo: permiteNegativo);
  for (final tecla in teclas.split('')) {
    valor = valor.digitar(tecla);
  }
  return valor;
}

void main() {
  group('digitar', () {
    test('começa em R\$ 0,00', () {
      expect(const ValorCaixaEletronico().texto, 'R\$ 0,00');
    });

    test('cada número entra pela direita, como no escopo', () {
      var valor = const ValorCaixaEletronico();
      final vistos = <String>[];
      for (final tecla in ['1', '2', '5', '0']) {
        valor = valor.digitar(tecla);
        vistos.add(valor.texto);
      }
      expect(vistos, ['R\$ 0,01', 'R\$ 0,12', 'R\$ 1,25', 'R\$ 12,50']);
      expect(valor.centavos, 1250);
    });

    test('vírgula, ponto e letras são ignorados', () {
      expect(digitarTudo('12,5.0a').centavos, 1250);
    });

    test('agrupa milhares', () {
      expect(digitarTudo('123456789').texto, 'R\$ 1.234.567,89');
    });

    test('para no limite de 11 números', () {
      final cheio = digitarTudo('99999999999');
      expect(cheio.centavos, ValorCaixaEletronico.maximoCentavos);
      expect(cheio.texto, 'R\$ 999.999.999,99');
      expect(cheio.digitar('9'), cheio);
    });
  });

  group('apagar', () {
    test('backspace tira o último número', () {
      expect(digitarTudo('1250').apagar().texto, 'R\$ 1,25');
    });

    test('apagar tudo volta para R\$ 0,00', () {
      var valor = digitarTudo('12');
      valor = valor.apagar().apagar().apagar();
      expect(valor.texto, 'R\$ 0,00');
    });
  });

  group('colar', () {
    const vazio = ValorCaixaEletronico();

    test('"12,50" vira R\$ 12,50', () {
      expect(vazio.colar('12,50').centavos, 1250);
    });

    test('aceita o símbolo e os milhares', () {
      expect(vazio.colar('R\$ 1.234,56').centavos, 123456);
    });

    test('texto sem centavos é lido como reais', () {
      expect(vazio.colar('300').centavos, 30000);
      expect(vazio.colar('1.234').centavos, 123400);
    });

    test('um número só depois da vírgula vira dezena de centavos', () {
      expect(vazio.colar('12,5').centavos, 1250);
      expect(vazio.colar('0.5').centavos, 50);
    });

    test('texto sem números não muda o valor', () {
      final valor = digitarTudo('99');
      expect(valor.colar('abc'), valor);
    });

    test('valor acima do máximo não muda o valor', () {
      expect(vazio.colar('1.000.000.000,00'), vazio);
    });

    test('sinal de menos é ignorado sem permiteNegativo', () {
      expect(vazio.colar('-12,50').centavos, 1250);
    });

    test('sinal de menos vale com permiteNegativo', () {
      const comSinal = ValorCaixaEletronico(permiteNegativo: true);
      expect(comSinal.colar('-12,50').centavos, -1250);
      expect(comSinal.colar('−R\$ 12,50').centavos, -1250);
    });
  });

  group('troca de sinal', () {
    test('"-" deixa negativo e mostra −R\$', () {
      final valor = digitarTudo('20000-', permiteNegativo: true);
      expect(valor.centavos, -20000);
      expect(valor.texto, '−R\$ 200,00');
    });

    test('"-" de novo volta para positivo', () {
      final valor = digitarTudo('20000--', permiteNegativo: true);
      expect(valor.centavos, 20000);
      expect(valor.texto, 'R\$ 200,00');
    });

    test('com o campo zerado, o sinal fica guardado para os próximos números', () {
      var valor = digitarTudo('-', permiteNegativo: true);
      expect(valor.texto, '−R\$ 0,00');
      valor = valor.digitar('5');
      expect(valor.centavos, -5);
    });

    test('apagar com o valor zerado tira o sinal', () {
      final valor = digitarTudo('-', permiteNegativo: true).apagar();
      expect(valor.texto, 'R\$ 0,00');
    });

    test('"-" é ignorado sem permiteNegativo', () {
      final valor = digitarTudo('200-');
      expect(valor.centavos, 200);
      expect(valor.texto, 'R\$ 2,00');
    });

    test('começa com valor negativo quando permitido', () {
      final valor = ValorCaixaEletronico.de(-20000, permiteNegativo: true);
      expect(valor.texto, '−R\$ 200,00');
      expect(valor.apagar().centavos, -2000);
    });
  });
}
