class Peca

  include ActiveModel::Model

  attr_reader :cor, :tipo, :lado_inicial #classes de baixo têm de ter esse atributo

  def initialize
    raise RuntimeError, 'cannot instantiate this class directly'
  end

  def set_cor(cor)
    @cor = cor
  end

  def set_lado_inicial(lado_inicial)
    @lado_inicial = lado_inicial
  end


end