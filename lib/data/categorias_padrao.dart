/// Categorias criadas junto com o banco, como na tabela "Categorias padrão"
/// do escopo. Ficam editáveis em Cadastros.
class CategoriaPadrao {
  const CategoriaPadrao(this.tipo, this.nome, [this.subcategorias = const []]);

  /// 'ganho' ou 'despesa'.
  final String tipo;
  final String nome;
  final List<String> subcategorias;
}

const categoriasPadrao = <CategoriaPadrao>[
  CategoriaPadrao('despesa', 'Casa', [
    'Aluguel',
    'Mercado',
    'Limpeza',
    'Contas de casa',
    'Manutenção',
  ]),
  CategoriaPadrao('despesa', 'Alimentação', [
    'Restaurantes',
    'Delivery',
    'Lanches',
  ]),
  CategoriaPadrao('despesa', 'Transporte', [
    'Combustível',
    'Transporte público',
    'Aplicativos de corrida',
  ]),
  CategoriaPadrao('despesa', 'Saúde', [
    'Remédios',
    'Consultas',
    'Plano de saúde',
  ]),
  CategoriaPadrao('despesa', 'Assinaturas', ['Streaming', 'Aplicativos']),
  CategoriaPadrao('despesa', 'Educação', ['Cursos', 'Livros']),
  CategoriaPadrao('despesa', 'Compras', ['Eletrônicos', 'Roupas', 'Presentes']),
  CategoriaPadrao('despesa', 'Lazer', ['Passeios', 'Viagens']),
  CategoriaPadrao('despesa', 'Taxas', ['Tarifas bancárias', 'Impostos']),
  CategoriaPadrao('despesa', 'Outros'),
  CategoriaPadrao('ganho', 'Salário'),
  CategoriaPadrao('ganho', 'Renda extra'),
  CategoriaPadrao('ganho', 'Reembolso'),
  CategoriaPadrao('ganho', 'Rendimentos'),
  CategoriaPadrao('ganho', 'Outros'),
];
