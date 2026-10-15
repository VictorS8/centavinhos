/// Uma ação num cadastro que as regras não permitem, como excluir uma conta
/// usada em lançamentos. [motivo] é a mensagem para mostrar na tela.
class CadastroBloqueado implements Exception {
  const CadastroBloqueado(this.motivo);

  final String motivo;

  @override
  String toString() => motivo;
}
