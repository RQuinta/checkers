class Movimento

  include ActiveModel::Validations

  attr_reader :tabuleiro,
              :casa_inicial,
              :casa_destino,
              :posicao_inicial,
              :posicao_destino,
              :qtd_remocoes_ainda_a_realizar,
              :peca_a_movimentar,
              :posicao_da_peca_no_caminho,
              :movimentos_com_remocao_a_realizar,
              :eh_com_remocao

  validate :esta_dentro_dos_limites,
           :posicoes_sao_validas,
           :movimento_eh_em_diagonal,
           :nao_tem_peca_do_mesmo_time_no_caminho,
           :nao_tem_mais_de_uma_peca_no_caminho

  validate :esta_fazendo_o_caminho_do_movimentos_a_realizar,
           if: Proc.new { @movimentos_com_remocao_a_realizar.any? }

  def initialize(params)
    @tabuleiro = params[:tabuleiro]
    @posicao_inicial = params[:posicao_inicial]
    @posicao_destino = params[:posicao_destino]
    @casa_inicial = @tabuleiro.get_casa(params[:posicao_inicial])
    @casa_destino = @tabuleiro.get_casa(params[:posicao_destino])
    @peca_a_movimentar = @casa_inicial.try(:peca)
    @qtd_remocoes_ainda_a_realizar = 0
    @movimentos_com_remocao_a_realizar = params[:movimentos_com_remocao_a_realizar] || []
    self.valid?
  end

  def as_json(options = nil)
    {:posicao_inicial => @posicao_inicial,
     :posicao_destino => @posicao_destino,
     :eh_com_remocao => @eh_com_remocao,
     :posicao_da_peca_no_caminho => posicao_da_peca_no_caminho,
     :movimentos_com_remocao_a_realizar => movimentos_com_remocao_a_realizar,
     :qtd_remocoes_ainda_a_realizar => @qtd_remocoes_ainda_a_realizar,
     :peca_a_movimentar => @peca_a_movimentar
    }
  end

  def ==(outro)
    @posicao_inicial == outro.posicao_inicial && @posicao_destino == outro.posicao_destino
  end


  def realiza_movimento
    if eh_com_remocao?
      come
    else
      @tabuleiro.movimenta_peca({:posicao_inicial => @posicao_inicial, :posicao_destino => @posicao_destino})
    end
  end

  # private

  def come
    @tabuleiro.remove_peca(posicao_da_peca_no_caminho)
    @tabuleiro.movimenta_peca({:posicao_inicial => @posicao_inicial, :posicao_destino => @posicao_destino})
  end

  def eh_com_remocao?
    @eh_com_remocao ||= posicao_da_peca_no_caminho.present?
  end

  def eh_em_diagonal?
    deslocamento_horizontal == deslocamento_vertical
  end

  def deslocamento_vertical
    (@posicao_destino.y - @posicao_inicial.y).abs
  end

  def deslocamento_horizontal
    (@posicao_destino.x - @posicao_inicial.x).abs
  end

  def movimento_para_frente?
    if @casa_inicial.peca.try(:lado_inicial) == Lado::BAIXO
      @posicao_destino.y > @posicao_inicial.y
    else
      @posicao_destino.y < @posicao_inicial.y
    end
  end

  def posicoes_da_diagonal
    posicoes = []
    deslocamento_x = 1 unless @posicao_inicial.x > @posicao_destino.x
    deslocamento_x = -1 if @posicao_inicial.x > @posicao_destino.x
    deslocamento_y = -1 unless @posicao_destino.y > @posicao_inicial.y
    deslocamento_y = 1 if @posicao_destino.y > @posicao_inicial.y
    posicao_atual = @posicao_inicial.dup
    for i in (1..deslocamento_vertical)
      posicao_atual.x += deslocamento_x
      posicao_atual.y += deslocamento_y
      posicoes << (posicao_atual.dup)
    end
    posicoes
  end

  def posicao_da_peca_no_caminho #pega posição da primeira peça que está no caminho do movimento
    unless @posicao_da_peca_no_caminho
      posicoes_da_diagonal.each do |posicao|
        @posicao_da_peca_no_caminho = posicao if @tabuleiro.existe_peca_na_posicao? posicao
      end
    end
    @posicao_da_peca_no_caminho
  end

  def nao_tem_mais_de_uma_peca_no_caminho
    posicoes_do_caminho = []
    posicoes_da_diagonal.each do |posicao|
      posicoes_do_caminho << posicao if @tabuleiro.existe_peca_na_posicao? posicao
    end
    errors.add(:mais_de_uma_peca_no_caminho, 'Existe mais de uma peça no caminho do movimento') if posicoes_do_caminho.count > 1
  end

  def esta_dentro_dos_limites
    [@posicao_inicial, @posicao_destino].each do |posicao|
      errors.add(:limites, 'Fora dos limites do tabuleiro.') unless Tabuleiro::LIMITES.member?(posicao.x) && Tabuleiro::LIMITES.member?(posicao.y)
    end
  end


  def posicoes_sao_validas
    errors.add(:sem_peca_na_casa_inicial, 'Não existe uma peça na casa de inicial.') unless @tabuleiro.existe_peca_na_posicao? @posicao_inicial
    errors.add(:peca_na_casa_destino, 'Já existe uma peça na casa de destino.') if @tabuleiro.existe_peca_na_posicao? @posicao_destino
    errors.add(:posicoes_sao_iguais, 'A posição de destino é igual à posição inicial.') if @posicao_destino == @posicao_inicial
  end

  def movimento_eh_em_diagonal
    if !eh_em_diagonal?
      errors.add(:diagonal, 'Movimento não é em diagonal.')
    end
  end

  def tem_peca_do_mesmo_time_no_caminho?
    posicoes_da_diagonal.each do |posicao|
      if @tabuleiro.get_casa(posicao).try(:peca).try(:cor) == @casa_inicial.try(:peca).try(:cor)
        return true
      end
    end
    false
  end

  def nao_tem_peca_do_mesmo_time_no_caminho
    errors.add(:peca_do_mesmo_time_no_caminho, 'Existe uma ou mais peças do mesmo time no caminho da jogada.') if tem_peca_do_mesmo_time_no_caminho?
  end

  def esta_fazendo_o_caminho_do_movimentos_a_realizar
    errors.add(:nao_esta_fazendo_o_caminho, 'Você não pode mudar de peça depois que começou um movimento.') unless @movimentos_com_remocao_a_realizar.include?(self)
  end

end