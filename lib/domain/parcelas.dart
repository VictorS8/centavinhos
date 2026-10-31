// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

/// Regras da compra parcelada no cartão.
library;

import 'dinheiro.dart';

/// Menor e maior número de parcelas de uma compra.
const minimoDeParcelas = 2;
const maximoDeParcelas = 48;

/// Valor de cada parcela de uma compra de [total] centavos em [n] vezes.
/// Os centavos que sobram da divisão vão para a primeira parcela.
List<int> dividirEmParcelas(int total, int n) {
  final base = total ~/ n;
  final sobra = total - base * n;
  return [for (var i = 0; i < n; i++) i == 0 ? base + sobra : base];
}

/// Parte de cada categoria em cada parcela de uma compra em [n] vezes.
/// [categorias] são os valores digitados para cada categoria, que somam o
/// total da compra. Devolve uma lista por parcela, com o valor de cada
/// categoria na mesma ordem; a soma de cada lista é o valor da parcela, e a
/// de cada categoria nas parcelas é o valor dela.
///
/// Da última parcela para a segunda, cada uma divide o seu valor entre as
/// categorias na proporção do que ainda falta de cada uma; as sobras vão
/// para as maiores frações (no empate, para a que vem primeiro). A primeira
/// parcela fica com o que restar. Uma categoria pode ficar com zero numa
/// parcela, mas só com valores de poucos centavos.
List<List<int>> dividirCategoriasEmParcelas(List<int> categorias, int n) {
  final total = categorias.fold(0, (soma, valor) => soma + valor);
  final parcelas = dividirEmParcelas(total, n);
  final faltam = [...categorias];
  final resultado = List<List<int>>.filled(n, const []);
  for (var p = n - 1; p >= 1; p--) {
    final valor = parcelas[p];
    final restante = faltam.fold(0, (soma, v) => soma + v);
    // Em BigInt: o produto de dois valores grandes passaria do int.
    final partes = <int>[];
    final fracoes = <BigInt>[];
    for (final f in faltam) {
      final produto = BigInt.from(valor) * BigInt.from(f);
      partes.add((produto ~/ BigInt.from(restante)).toInt());
      fracoes.add(produto.remainder(BigInt.from(restante)));
    }
    var sobra = valor - partes.fold(0, (soma, v) => soma + v);
    final ordem = [for (var i = 0; i < faltam.length; i++) i]
      ..sort((a, b) {
        final porFracao = fracoes[b].compareTo(fracoes[a]);
        return porFracao != 0 ? porFracao : a.compareTo(b);
      });
    for (final i in ordem) {
      if (sobra == 0) break;
      partes[i]++;
      sobra--;
    }
    for (var i = 0; i < faltam.length; i++) {
      faltam[i] -= partes[i];
    }
    resultado[p] = partes;
  }
  resultado[0] = faltam;
  return resultado;
}

/// Como a compra fica dividida, para mostrar ao lado do campo Parcelas:
/// "3x de R$ 100,00" ou, com sobra, "1x de R$ 100,02 e 2x de R$ 100,00".
String textoDasParcelas(int total, int n) {
  final parcelas = dividirEmParcelas(total, n);
  final primeira = parcelas.first;
  final demais = parcelas.last;
  if (primeira == demais) return '${n}x de ${formatarCentavos(demais)}';
  return '1x de ${formatarCentavos(primeira)} e ${n - 1}x de ${formatarCentavos(demais)}';
}
