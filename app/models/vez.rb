class Vez

  attr_reader :jogador

  def initialize(jogador)
    @jogador = jogador
  end

  def muda_de_vez(jogador)
    @jogador = jogador
  end


end