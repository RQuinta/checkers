class Jogador

  attr_reader :cor_das_pecas, :tipo #classes de baixo têm de ter esse atributo

  def initialize
    raise RuntimeError, 'cannot instantiate this class directly'
  end

  def set_cor_de_suas_pecas(cor)
    @cor_das_pecas = cor
  end

end