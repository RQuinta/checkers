class MovimentoDama < Movimento

  validate :posicao_incial_eh_uma_dama

  def initialize(params) #espera os mesmos parametros de movimento: posicao_inicial, posicao_destino e o tabuleiro
    super(params)
    self.valid?
    if self.errors.empty?
      @eh_com_remocao = eh_com_remocao?
      if @eh_com_remocao
        pega_outros_possiveis_movimentos
      else
        realiza_movimento
      end
    end
  end

  def realiza_movimento
    super if self.errors.empty?
  end

  private

  def pega_outros_possiveis_movimentos
    movimentos = []
    realiza_movimento
    tabuleiro = Marshal.load(Marshal.dump(@tabuleiro))
    movimentos << MovimentoDama.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x - 2, :y => @posicao_destino.y - 2)}) #esquerda, baixo
    movimentos << MovimentoDama.new({:tabuleiro => tabuleiro,
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x + 2, :y => @posicao_destino.y + 2)}) #direita, cima
    movimentos << MovimentoDama.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x - 2, :y => @posicao_destino.y + 2)}) #esquerda, cima
    movimentos << MovimentoDama.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x + 2, :y => @posicao_destino.y - 2)}) #direita, baixo
    movimentos_com_remocao = movimentos.select { |movimento| movimento if movimento.errors.empty? && movimento.eh_com_remocao }
    if movimentos_com_remocao.any?
      max = movimentos_com_remocao.max_by { |el| el.qtd_remocoes_ainda_a_realizar }.qtd_remocoes_ainda_a_realizar
      @movimentos_com_remocao_a_realizar = movimentos_com_remocao.select { |el| el.qtd_remocoes_ainda_a_realizar == max }
      @qtd_remocoes_ainda_a_realizar = max + 1
    end
  end

  def posicao_incial_eh_uma_dama
    errors.add(:peao, 'Há um peão, e não uma dama na casa inicial') if @peca_a_movimentar.try(:tipo) == Peao::TIPO_PEAO
  end

end
