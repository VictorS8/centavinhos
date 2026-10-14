// Relatório de uma etapa: roda o flutter analyze, os testes rápidos (com as
// capturas de tela) e os testes de integração no Windows, e gera
// relatorios/etapa-N/index.html com tudo, incluindo o roteiro manual.
//
// Uso:
//   dart run tool/relatorio.dart <etapa> [--sem-integracao] [--nao-abrir]
//
// Sai com código 1 se o analyze ou algum teste falhar.

import 'dart:convert';
import 'dart:io';

const _categorias = [
  ('domain', 'Regras (lib/domain)'),
  ('data', 'Banco'),
  ('ui', 'Interface'),
  ('golden', 'Capturas de tela'),
  ('integracao', 'App real (integração)'),
  ('outros', 'Outros'),
];

class _Teste {
  _Teste({required this.arquivo, required this.nome, required this.categoria, required this.inicio});

  final String arquivo;
  final String nome;
  final String categoria;
  final int inicio;
  String resultado = 'executando';
  int duracaoMs = 0;
  final erros = <String>[];
  bool novo = false;

  String get chave => '$arquivo :: $nome';
  bool get passou => resultado == 'success';
}

Future<void> main(List<String> argumentos) async {
  final etapa = argumentos.firstWhere((a) => !a.startsWith('--'), orElse: () => '');
  if (int.tryParse(etapa) == null) {
    stderr.writeln('Uso: dart run tool/relatorio.dart <etapa> [--sem-integracao] [--nao-abrir]');
    exit(64);
  }
  final comIntegracao = !argumentos.contains('--sem-integracao');
  final abrir = !argumentos.contains('--nao-abrir');
  final pasta = Directory('relatorios/etapa-$etapa')..createSync(recursive: true);

  stdout.writeln('1/3 flutter analyze...');
  final analise = await _rodar(['analyze']);

  stdout.writeln('2/3 flutter test (regras, banco, interface e capturas)...');
  final rapidos = await _rodar(['test', '--reporter', 'json']);
  final testes = _lerTestes(rapidos.stdout);

  if (comIntegracao) {
    stdout.writeln('3/3 flutter test integration_test -d windows (abre o app)...');
    final integracao = await _rodar(['test', 'integration_test', '-d', 'windows', '--reporter', 'json']);
    testes.addAll(_lerTestes(integracao.stdout));
  } else {
    stdout.writeln('3/3 testes de integração pulados (--sem-integracao).');
  }

  // Marca os testes que não estavam no relatório da etapa anterior.
  final anterior = File('relatorios/etapa-${int.parse(etapa) - 1}/testes.json');
  final chavesAnteriores = anterior.existsSync()
      ? (json.decode(anterior.readAsStringSync()) as List).cast<String>().toSet()
      : <String>{};
  for (final teste in testes) {
    teste.novo = !chavesAnteriores.contains(teste.chave);
  }
  File('${pasta.path}/testes.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(testes.map((t) => t.chave).toList()..sort()),
  );

  final capturas = _copiarImagens('test/golden/capturas', '${pasta.path}/capturas');
  final falhasVisuais = _copiarImagens('test/golden/failures', '${pasta.path}/falhas');

  final roteiro = File('${pasta.path}/roteiro-manual.md');
  final html = _montarHtml(
    etapa: etapa,
    analise: analise,
    testes: testes,
    comIntegracao: comIntegracao,
    capturas: capturas,
    falhasVisuais: falhasVisuais,
    roteiro: roteiro.existsSync() ? roteiro.readAsStringSync() : null,
  );
  final pagina = File('${pasta.path}/index.html')..writeAsStringSync(html);

  final falharam = testes.where((t) => !t.passou).toList();
  stdout
    ..writeln()
    ..writeln('flutter analyze: ${analise.exitCode == 0 ? 'sem problemas' : 'COM PROBLEMAS'}')
    ..writeln('Testes: ${testes.length - falharam.length} passaram, ${falharam.length} falharam'
        ' (${testes.where((t) => t.novo).length} novos nesta etapa)');
  for (final teste in falharam) {
    stdout.writeln('  ✗ ${teste.arquivo}: ${teste.nome}');
  }
  stdout.writeln('Relatório: ${pagina.absolute.path}');

  if (abrir) {
    await Process.run('cmd', ['/c', 'start', '', pagina.absolute.path]);
  }
  exit(analise.exitCode == 0 && falharam.isEmpty ? 0 : 1);
}

Future<ProcessResult> _rodar(List<String> argumentos) => Process.run(
  'flutter',
  argumentos,
  runInShell: true,
  stdoutEncoding: utf8,
  stderrEncoding: utf8,
);

/// Lê a saída do `flutter test --reporter json`, um evento por linha.
List<_Teste> _lerTestes(Object? saida) {
  final caminhos = <int, String>{};
  final porId = <int, _Teste>{};
  final testes = <_Teste>[];
  for (final linha in LineSplitter.split(saida as String)) {
    final Map<String, dynamic> evento;
    try {
      final lido = json.decode(linha);
      if (lido is! Map<String, dynamic>) continue;
      evento = lido;
    } on FormatException {
      continue; // Linhas que não são eventos, como "Building Windows application...".
    }
    switch (evento['type']) {
      case 'suite':
        final suite = evento['suite'] as Map<String, dynamic>;
        caminhos[suite['id'] as int] = _relativo(suite['path'] as String? ?? '');
      case 'testStart':
        final info = evento['test'] as Map<String, dynamic>;
        final arquivo = caminhos[info['suiteID']] ?? '';
        final teste = _Teste(
          arquivo: arquivo,
          nome: info['name'] as String,
          categoria: _categoriaDe(arquivo),
          inicio: evento['time'] as int,
        );
        porId[info['id'] as int] = teste;
        testes.add(teste);
      case 'error':
        porId[evento['testID']]?.erros.add(evento['error'] as String);
      case 'testDone':
        final teste = porId[evento['testID']];
        if (teste == null) continue;
        if (evento['hidden'] == true) {
          // "loading", setUpAll e tearDownAll: só aparecem se falharem.
          if (evento['result'] == 'success') testes.remove(teste);
        }
        teste
          ..resultado = evento['result'] as String
          ..duracaoMs = (evento['time'] as int) - teste.inicio;
    }
  }
  return testes;
}

String _relativo(String caminho) {
  final normal = caminho.replaceAll(r'\', '/');
  final raiz = '${Directory.current.path.replaceAll(r'\', '/')}/';
  return normal.toLowerCase().startsWith(raiz.toLowerCase())
      ? normal.substring(raiz.length)
      : normal;
}

String _categoriaDe(String arquivo) {
  if (arquivo.startsWith('integration_test/')) return 'integracao';
  for (final pasta in ['domain', 'data', 'ui', 'golden']) {
    if (arquivo.startsWith('test/$pasta/')) return pasta;
  }
  return 'outros';
}

/// Ordena [testes] pela posição do arquivo em [arquivos], sem trocar a ordem
/// dos testes de um mesmo arquivo.
void _agruparPorArquivo(List<_Teste> testes, List<String> arquivos) {
  final ordenados = [
    for (final arquivo in arquivos) ...testes.where((t) => t.arquivo == arquivo),
  ];
  testes
    ..clear()
    ..addAll(ordenados);
}

/// Copia os PNGs de [origem] para [destino] e devolve os nomes.
List<String> _copiarImagens(String origem, String destino) {
  final pastaDestino = Directory(destino);
  if (pastaDestino.existsSync()) pastaDestino.deleteSync(recursive: true);
  final pastaOrigem = Directory(origem);
  if (!pastaOrigem.existsSync()) return [];
  final nomes = <String>[];
  for (final arquivo in pastaOrigem.listSync().whereType<File>()) {
    if (!arquivo.path.endsWith('.png')) continue;
    pastaDestino.createSync(recursive: true);
    final nome = arquivo.uri.pathSegments.last;
    arquivo.copySync('$destino/$nome');
    nomes.add(nome);
  }
  return nomes..sort();
}

final _escapar = const HtmlEscape(HtmlEscapeMode.element).convert;
final _escaparAtributo = const HtmlEscape(HtmlEscapeMode.attribute).convert;

String _montarHtml({
  required String etapa,
  required ProcessResult analise,
  required List<_Teste> testes,
  required bool comIntegracao,
  required List<String> capturas,
  required List<String> falhasVisuais,
  required String? roteiro,
}) {
  final agora = DateTime.now();
  String dois(int n) => n.toString().padLeft(2, '0');
  final quando =
      '${dois(agora.day)}/${dois(agora.month)}/${agora.year} ${dois(agora.hour)}:${dois(agora.minute)}';
  final falharam = testes.where((t) => !t.passou).length;
  final novos = testes.where((t) => t.novo).length;
  final analiseOk = analise.exitCode == 0;

  final secoes = StringBuffer();
  for (final (chave, titulo) in _categorias) {
    // Os arquivos rodam em paralelo; agrupa por arquivo mantendo a ordem de
    // cada um.
    final daCategoria = testes.where((t) => t.categoria == chave).toList();
    final ordemDosArquivos = daCategoria.map((t) => t.arquivo).toSet().toList()..sort();
    _agruparPorArquivo(daCategoria, ordemDosArquivos);
    if (daCategoria.isEmpty) {
      if (chave == 'integracao' && !comIntegracao) {
        secoes.writeln('<section><h3>$titulo</h3><p class="apoio">Pulados nesta execução.</p></section>');
      }
      continue;
    }
    final ok = daCategoria.where((t) => t.passou).length;
    final temFalha = ok != daCategoria.length;
    secoes.writeln('<details${temFalha || daCategoria.any((t) => t.novo) ? ' open' : ''}>');
    secoes.writeln(
      '<summary><span class="titulo">$titulo</span>'
      '<span class="contagem ${temFalha ? 'ruim' : 'bom'}">$ok de ${daCategoria.length}</span></summary>',
    );
    secoes.writeln('<ul class="testes">');
    String? arquivoAtual;
    for (final teste in daCategoria) {
      if (teste.arquivo != arquivoAtual) {
        arquivoAtual = teste.arquivo;
        secoes.writeln('<li class="arquivo">${_escapar(teste.arquivo)}</li>');
      }
      final duracao = teste.duracaoMs >= 1000 ? '${(teste.duracaoMs / 1000).toStringAsFixed(1)} s' : '';
      secoes.writeln(
        '<li class="${teste.passou ? 'passou' : 'falhou'}">'
        '<span class="icone">${teste.passou ? '✓' : '✗'}</span>'
        '${teste.novo ? '<span class="novo">novo</span>' : ''}'
        '<span class="nome">${_escapar(teste.nome)}</span>'
        '<span class="tempo">$duracao</span>'
        '${teste.erros.isEmpty ? '' : '<pre>${_escapar(teste.erros.join('\n\n'))}</pre>'}'
        '</li>',
      );
    }
    secoes.writeln('</ul></details>');
  }

  String galeria(List<String> imagens, String pasta) => imagens
      .map(
        (nome) =>
            '<figure><a href="$pasta/$nome"><img src="$pasta/$nome" alt="${_escapar(nome)}" loading="lazy"></a>'
            '<figcaption>${_escapar(nome.replaceAll('.png', '').replaceAll('_', ' '))}</figcaption></figure>',
      )
      .join('\n');

  return '''<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Etapa $etapa · Centavinhos</title>
<style>
:root { --fundo:#F5FBF7; --cartao:#FFFFFF; --texto:#171D1A; --apoio:#3F4945; --borda:#BFC9C3;
  --primaria:#1F6F5C; --bom:#1F6F5C; --bom-fundo:#A6F2DB; --ruim:#BA1A1A; --ruim-fundo:#FFDAD6; --novo-fundo:#C5E7FF; --novo-texto:#001E2D; }
@media (prefers-color-scheme: dark) { :root { --fundo:#0F1512; --cartao:#171D1A; --texto:#DEE4DF; --apoio:#BFC9C3;
  --borda:#3F4945; --primaria:#8AD6BF; --bom:#8AD6BF; --bom-fundo:#005142; --ruim:#FFB4AB; --ruim-fundo:#93000A; --novo-fundo:#284B5F; --novo-texto:#C5E7FF; } }
* { box-sizing:border-box; }
body { margin:0; background:var(--fundo); color:var(--texto); font:15px/1.5 "Segoe UI", Roboto, sans-serif; }
main { max-width:1080px; margin:0 auto; padding:32px 16px 64px; }
h1 { font-size:28px; margin:0 0 4px; } h2 { font-size:20px; margin:40px 0 12px; } h3 { font-size:16px; margin:24px 0 8px; }
.apoio { color:var(--apoio); }
.resumo { display:flex; flex-wrap:wrap; gap:12px; margin:24px 0; }
.bloco { background:var(--cartao); border:1px solid var(--borda); border-radius:16px; padding:16px 20px; min-width:180px; }
.bloco b { display:block; font-size:24px; }
.bom { color:var(--bom); } .ruim { color:var(--ruim); }
details { background:var(--cartao); border:1px solid var(--borda); border-radius:16px; margin:12px 0; padding:4px 16px; }
summary { cursor:pointer; padding:10px 0; display:flex; justify-content:space-between; gap:12px; }
summary .titulo { font-weight:600; }
ul.testes { list-style:none; margin:0 0 12px; padding:0; }
ul.testes li { padding:6px 0; border-top:1px solid var(--borda); display:flex; flex-wrap:wrap; gap:8px; align-items:baseline; }
ul.testes li.arquivo { color:var(--apoio); font:12px Consolas, monospace; border-top:none; padding-top:12px; }
.icone { width:16px; font-weight:700; } .passou .icone { color:var(--bom); } .falhou .icone { color:var(--ruim); }
.falhou { background:var(--ruim-fundo); border-radius:8px; padding:6px 8px !important; }
.nome { flex:1; min-width:200px; } .tempo { color:var(--apoio); font-size:13px; }
.novo { background:var(--novo-fundo); color:var(--novo-texto); border-radius:8px; padding:0 8px; font-size:12px; font-weight:600; }
pre { width:100%; overflow-x:auto; background:var(--fundo); padding:12px; border-radius:8px; font-size:12px; white-space:pre-wrap; }
.galeria { display:grid; grid-template-columns:repeat(auto-fill, minmax(300px, 1fr)); gap:16px; }
figure { margin:0; background:var(--cartao); border:1px solid var(--borda); border-radius:16px; padding:8px; }
figure img { width:100%; border-radius:8px; display:block; } figcaption { padding:8px 4px 0; color:var(--apoio); font-size:13px; }
.roteiro { background:var(--cartao); border:1px solid var(--borda); border-radius:16px; padding:8px 24px 16px; }
.roteiro li { margin:4px 0; } .roteiro ul.marcar { list-style:none; padding-left:4px; }
.roteiro label { cursor:pointer; display:flex; gap:10px; align-items:baseline; }
.roteiro input[type=checkbox] { accent-color:var(--primaria); width:16px; height:16px; flex:none; transform:translateY(2px); }
.roteiro li.feito { color:var(--apoio); }
#limpar-roteiro { margin-left:8px; font:inherit; font-size:13px; color:var(--primaria); background:none; border:1px solid var(--borda); border-radius:16px; padding:2px 12px; cursor:pointer; }
code { font-family:Consolas, monospace; font-size:13px; background:var(--fundo); padding:1px 4px; border-radius:4px; }
</style>
</head>
<body><main>
<h1>Centavinhos · Etapa $etapa</h1>
<p class="apoio">Gerado em $quando</p>

<div class="resumo">
  <div class="bloco"><span class="apoio">flutter analyze</span><b class="${analiseOk ? 'bom' : 'ruim'}">${analiseOk ? 'Sem problemas' : 'Com problemas'}</b></div>
  <div class="bloco"><span class="apoio">Testes</span><b class="${falharam == 0 ? 'bom' : 'ruim'}">${testes.length - falharam} de ${testes.length}</b></div>
  <div class="bloco"><span class="apoio">Novos nesta etapa</span><b>$novos</b></div>
  <div class="bloco"><span class="apoio">Capturas de tela</span><b>${capturas.length}</b></div>
</div>

${analiseOk ? '' : '<h2>flutter analyze</h2><pre>${_escapar('${analise.stdout}${analise.stderr}')}</pre>'}

<h2>Testes</h2>
$secoes

${falhasVisuais.isEmpty ? '' : '<h2 class="ruim">Diferenças nas capturas</h2><div class="galeria">${galeria(falhasVisuais, 'falhas')}</div>'}

<h2>Capturas de tela</h2>
${capturas.isEmpty ? '<p class="apoio">Nenhuma captura.</p>' : '<div class="galeria">${galeria(capturas, 'capturas')}</div>'}

<h2 id="roteiro">Roteiro para testar na mão</h2>
${roteiro == null ? '' : '''<p class="apoio"><b id="contador-roteiro"></b> · As marcações ficam só neste navegador; o <code>roteiro-manual.md</code> não muda.
<button id="limpar-roteiro" type="button">Limpar marcações</button></p>'''}
<div class="roteiro">${roteiro == null ? '<p class="apoio">Ainda não há <code>roteiro-manual.md</code> nesta etapa.</p>' : _markdownSimples(roteiro)}</div>
</main>
<script>
// Caixas do roteiro clicáveis, guardadas só neste navegador. Vale o clique,
// a não ser que o item tenha mudado no .md depois dele: aí vale o .md.
(function () {
  var chave = 'centavinhos-roteiro-etapa-$etapa';
  var salvo = {};
  try { salvo = JSON.parse(localStorage.getItem(chave) || '{}'); } catch (e) {}
  var caixas = document.querySelectorAll('.roteiro input[type=checkbox]');
  var contador = document.getElementById('contador-roteiro');
  function atualizar() {
    var feitos = 0;
    caixas.forEach(function (caixa) {
      if (caixa.checked) feitos++;
      caixa.closest('li').classList.toggle('feito', caixa.checked);
    });
    if (contador) contador.textContent = feitos + ' de ' + caixas.length + ' conferidos';
  }
  caixas.forEach(function (caixa) {
    var item = caixa.dataset.item;
    var doMd = caixa.dataset.md === '1';
    var anterior = salvo[item];
    caixa.checked = anterior && anterior.md === doMd ? anterior.marcado : doMd;
    caixa.addEventListener('change', function () {
      salvo[item] = { marcado: caixa.checked, md: doMd };
      try { localStorage.setItem(chave, JSON.stringify(salvo)); } catch (e) {}
      atualizar();
    });
  });
  var limpar = document.getElementById('limpar-roteiro');
  if (limpar) {
    limpar.addEventListener('click', function () {
      try { localStorage.removeItem(chave); } catch (e) {}
      location.reload();
    });
  }
  atualizar();
})();
</script>
</body>
</html>
''';
}

/// Converte o pouco de Markdown usado no roteiro: títulos, listas, caixas de
/// marcar, citações, **negrito** e `código`.
String _markdownSimples(String texto) {
  String emLinha(String s) => _escapar(s)
      .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => '<code>${m[1]}</code>')
      .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => '<b>${m[1]}</b>');

  final saida = StringBuffer();
  String? listaAberta;
  void fecharLista() {
    if (listaAberta != null) saida.writeln('</${listaAberta == 'ol' ? 'ol' : 'ul'}>');
    listaAberta = null;
  }

  void abrirLista(String tipo) {
    if (listaAberta == tipo) return;
    fecharLista();
    saida.writeln(switch (tipo) {
      'ol' => '<ol>',
      'marcar' => '<ul class="marcar">',
      _ => '<ul>',
    });
    listaAberta = tipo;
  }

  for (final linha in LineSplitter.split(texto)) {
    final l = linha.trimRight();
    // Aceita [ ], [x], [X] e também [ x ], com espaços.
    final caixa = RegExp(r'^\s*[-*] \[\s*([xX]?)\s*\] (.*)$').firstMatch(l);
    final numerada = RegExp(r'^\s*\d+\. (.*)$').firstMatch(l);
    final item = RegExp(r'^\s*[-*] (.*)$').firstMatch(l);
    if (l.startsWith('#')) {
      fecharLista();
      final nivel = RegExp(r'^#+').firstMatch(l)![0]!.length;
      final tag = nivel <= 1 ? 'h3' : 'h4';
      saida.writeln('<$tag>${emLinha(l.substring(nivel).trim())}</$tag>');
    } else if (caixa != null) {
      abrirLista('marcar');
      final marcada = caixa[1]!.isNotEmpty;
      saida.writeln(
        '<li><label><input type="checkbox" data-item="${_escaparAtributo(caixa[2]!)}" '
        'data-md="${marcada ? 1 : 0}"${marcada ? ' checked' : ''}> ${emLinha(caixa[2]!)}</label></li>',
      );
    } else if (numerada != null) {
      abrirLista('ol');
      saida.writeln('<li>${emLinha(numerada[1]!)}</li>');
    } else if (item != null) {
      abrirLista('ul');
      saida.writeln('<li>${emLinha(item[1]!)}</li>');
    } else if (l.startsWith('>')) {
      fecharLista();
      saida.writeln('<p class="apoio">${emLinha(l.substring(1).trim())}</p>');
    } else if (l.isEmpty) {
      fecharLista();
    } else {
      fecharLista();
      saida.writeln('<p>${emLinha(l)}</p>');
    }
  }
  fecharLista();
  return saida.toString();
}
