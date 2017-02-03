class Peao < Peca

  TIPO_PEAO = 'PEAO'

  def initialize(params)
    set_cor params[:cor]
    set_lado_inicial params[:lado_inicial]
    @tipo = TIPO_PEAO
  end

  def valida_movimentacao(params)
    MovimentoPeao.new(params)
  end

  def vira_dama(casa)
    casa.peca = Dama.new({:cor => @cor, :lado_inicial => @lado_inicial})
  end

  def chegou_do_outro_lado?(posicao_atual)
    if @lado_inicial == Lado::CIMA
      return true if posicao_atual.y == Tabuleiro::LIMITES.first
    else
      return true if posicao_atual.y == Tabuleiro::LIMITES.last
    end
  end

end