class MovimentoPeao < Movimento

  validate :deslocamento_menor_que_dois
  validate :eh_pra_frente,
           if: Proc.new { !@eh_com_remocao }
  validate :movimento_eh_com_remocao,
           if: Proc.new { deslocamento_vertical == 2 }
  validate :posicao_incial_eh_um_peao
  validate :valida_remocao

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
    @peca_vira_dama = false
    if self.errors.empty?
      if hora_de_virar_dama?(@peca_a_movimentar)
        @peca_a_movimentar.vira_dama(@casa_destino)
        @peca_vira_dama = true
      end
    end
  end

  def as_json(options = nil)
    super.merge(:peca_vira_dama => @peca_vira_dama)
  end

  def realiza_movimento
    if self.errors.empty?
      super #realiza movimento
    end
  end


  private

  def pega_outros_possiveis_movimentos
    realiza_movimento
    movimentos = []
    movimentos << MovimentoPeao.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x + 2, :y => @posicao_destino.y + 2)}) #direita, cima
    movimentos << MovimentoPeao.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x - 2, :y => @posicao_destino.y + 2)}) #esquerda, cima
    movimentos << MovimentoPeao.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x + 2, :y => @posicao_destino.y - 2)}) #direita, baixo
    movimentos << MovimentoPeao.new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)),
                                     :posicao_inicial => @posicao_destino,
                                     :posicao_destino => PosicaoTabuleiro.new(:x => @posicao_destino.x - 2, :y => @posicao_destino.y - 2)}) #esquerda, baixo
    movimentos_com_remocao = movimentos.select { |movimento| movimento if movimento.errors.empty? && movimento.eh_com_remocao? }
    if movimentos_com_remocao.any?
      max = movimentos_com_remocao.max_by { |el| el.qtd_remocoes_ainda_a_realizar }.qtd_remocoes_ainda_a_realizar
      @movimentos_com_remocao_a_realizar = movimentos_com_remocao.select { |el| el.qtd_remocoes_ainda_a_realizar == max }
      @qtd_remocoes_ainda_a_realizar = max + 1
    end
  end

  def posicao_incial_eh_um_peao
    errors.add(:dama, 'Há uma dama, e não um peão na casa inicial') if @casa_inicial.peca.try(:tipo) == Dama::TIPO_DAMA
  end

  def movimento_eh_com_remocao
    errors.add(:movimento_com_remocao, 'Não existe peça a ser comida para que seja efetuado um salto de duas casas') unless @eh_com_remocao
  end

  def eh_pra_frente
    errors.add(:movimento_nao_e_para_frente, 'Movimento não é para frente') unless movimento_para_frente?
  end

  def deslocamento_menor_que_dois
    errors.add(:deslocamento_vertical_maior_que_dois, 'O deslocamento vertical é maior que dois') if deslocamento_vertical > 2
    errors.add(:deslocamento_horizontal_maior_que_dois, 'O deslocamento horizontal  é maior que dois') if deslocamento_horizontal > 2
  end

  def valida_remocao
    if eh_com_remocao? && self.errors.empty?
      proxima_casa_diagonal = @tabuleiro.get_casa(posicoes_da_diagonal[posicoes_da_diagonal.index(posicao_da_peca_no_caminho).next])
      errors.add(:remocao, 'Movimento não é para casa logo após a peça adversária.') unless proxima_casa_diagonal.posicao == @posicao_destino
    end
  end

  def hora_de_virar_dama?(peca)
    if @qtd_remocoes_ainda_a_realizar == 0
      if peca.lado_inicial == Lado::CIMA
        return true if @posicao_destino.y == Tabuleiro::LIMITES.first
      else
        return true if @posicao_destino.y == Tabuleiro::LIMITES.last
      end
    end
    false
  end

end
