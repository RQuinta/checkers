class Partida

  include ActiveModel::Model
  attr_reader :vez, :tabuleiro, :jogadores, :identificador

  HUMANOVSIA = :humanovsia
  HUMANOVSHUMANO = :humanovshumano
  IAVSIA = :iavsia

  @@numero_de_partidas = 0

  def initialize(params)
    jogador1 = instancia_jogador_de_acordo_com_tipo params[:jogador1]
    jogador2 = instancia_jogador_de_acordo_com_tipo params[:jogador2]
    @jogadores = [jogador1, jogador2]
    @vez = Vez.new sorteia_jogador
    set_cor_das_pecas_dos_jogadores
    if @vez.jogador.tipo == Humano::TIPO_HUMANO #se o humano tem a primeira jogada as peças brancas ficam embaixo
      @tabuleiro = Tabuleiro.new @vez.jogador.cor_das_pecas
    else #se o humano não tem a primeira jogada, as peças brancas ficam em cima
      @tabuleiro = Tabuleiro.new jogador_que_nao_e_da_vez.cor_das_pecas
    end
    @identificador = @@numero_de_partidas += 1
  end

  def valida_movimentacao(params) #espera receber uma hash com posicao_inicial e posicao_destino com seus valores
    peca = @tabuleiro.get_peca(params[:posicao_inicial])
    erros = nil, movimento = nil, resposta = false
    if peca.nil?
      erros = ['Não há uma peça na casa inicial.']
    else
      movimento = peca.valida_movimentacao(params.merge({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro))}))
      if movimento.errors.any?
        resposta = false
        erros = movimento.errors.map { |attribute, message| "#{message}" }
      else
        movimento_com_mais_remocoes =
            EstadosSucessores.
                new({:tabuleiro => Marshal.load(Marshal.dump(@tabuleiro)), :cor_das_pecas => peca.cor}).
                movimento_com_mais_remocoes_possiveis
        if movimento_com_mais_remocoes.nil? #se estiver é pq não existe nenhum movimento com remoção a realizar
          resposta = true
          @tabuleiro = movimento.tabuleiro
        else
          if movimento_com_mais_remocoes.include? movimento
            resposta = true
            @tabuleiro = movimento.tabuleiro
          else
            resposta = false
            erros = ['Há um movimento com mais remoções a ser realizado']
          end
        end
      end
      @tabuleiro.atualiza_contadores(movimento); atualiza_vez(movimento) if resposta == true
    end
    {:resposta => resposta, :vez => @vez, :erros => erros, :movimento => movimento.as_json, :acabou => @tabuleiro.acabou?}
  end

  def pega_movimento_ia
    if @jogadores.select { |jogador| jogador.tipo == IA::TIPO_IA }.empty?
      return {:erro => 'Não há uma IA na partida para que seja chamado o método de pegar movimento da IA.'}
    else
      if @vez.jogador.tipo == IA::TIPO_IA
        retorno = @vez.jogador.min_max_decision(@tabuleiro)
        atualiza_tabuleiro(retorno[:tabuleiro])
        muda_de_vez
        retorno.merge({:vez => @vez, :acabou => tabuleiro.acabou?, :movimentos => retorno[:movimentos]})
      else
        return {:erro => 'Não está na vez da IA jogar.'}
      end
    end
  end

  def atualiza_tabuleiro(tabuleiro)
    @tabuleiro = tabuleiro
  end

  private

  def atualiza_vez(movimento)
    muda_de_vez if movimento.movimentos_com_remocao_a_realizar.empty?
  end


  def movimentar(params)
    @tabuleiro = params[:tabuleiro]
    casa_inicial = @tabuleiro.get_peca(params[:posicao_inicial])
    casa_destino = @tabuleiro.get_peca(params[:posicao_destino])
    casa_destino.peca = casa_inicial.peca
    casa_inicial.peca = nil
  end

  def muda_de_vez
    @vez.muda_de_vez(jogador_que_nao_e_da_vez)
  end

  def jogador_que_nao_e_da_vez
    @jogadores.select { |jogador| jogador != @vez.jogador }.first
  end

  def set_cor_das_pecas_dos_jogadores
    @vez.jogador.set_cor_de_suas_pecas(Cor::BRANCA)
    jogador_que_nao_e_da_vez.set_cor_de_suas_pecas(Cor::PRETA)
  end

  def pega_humano
    return @jogadores if @jogadores.first.tipo == Humano::TIPO_HUMANO && @jogadores.last.tipo == Humano::TIPO_HUMANO
    return @jogadores.first if @jogadores.first.tipo == Humano::TIPO_HUMANO
    return @jogadores.last if @jogadores.last.tipo == Humano::TIPO_HUMANO
  end

  def tipo_partida
    tipos = @jogadores.map { |jogador| jogador.tipo }
    return IAVSIA unless tipos.include? Humano::TIPO_HUMANO
    return HUMANOVSHUMANO unless tipos.include? IA::TIPO_IA
    return HUMANOVSIA
  end

  def instancia_jogador_de_acordo_com_tipo(tipo)
    if tipo == Humano::TIPO_HUMANO
      Humano.new
    elsif tipo == IA::TIPO_IA
      IA.new
    end
  end

  def sorteia_jogador
    @jogadores.sample
  end


end