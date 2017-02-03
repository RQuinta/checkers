class Dama < Peca

  TIPO_DAMA = 'DAMA'

  def initialize(params)
    set_cor params[:cor]
    set_lado_inicial params[:lado_inicial]
    @tipo = TIPO_DAMA
  end

  def valida_movimentacao(params)
    MovimentoDama.new(params)
  end

end
