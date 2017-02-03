require 'singleton'

class BancoPartida

  include Singleton

  def initialize
    @partidas = []
  end

  def adiciona_partida(partida)
    @partidas << partida
  end

  def pega_partida(identificador)
    @partidas.select { |partida| partida.identificador == identificador }.first
  end

  def apaga_partida(identificador)
    posicao_partida_no_array = @partidas.index(pega_partida(identificador))
    @partidas.delete_at(posicao_partida_no_array)
  end

end
