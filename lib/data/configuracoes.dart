/// Chaves da tabela `configuracoes` e os valores com que o banco nasce.
abstract final class ChaveConfiguracao {
  /// verde | roxo | azul | sistema
  static const temaCor = 'tema_cor';

  /// sistema | claro | escuro
  static const temaModo = 'tema_modo';

  /// 0 | 1
  static const boasVindasConcluida = 'boas_vindas_concluida';
}

const configuracoesPadrao = <String, String>{
  ChaveConfiguracao.temaCor: 'verde',
  ChaveConfiguracao.temaModo: 'sistema',
  ChaveConfiguracao.boasVindasConcluida: '0',
};
