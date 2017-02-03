class IA < Jogador

  include MovimentosHelper

  TIPO_IA = 'IA'
  PROFUNDIDADE_MAXIMA = 0

  def initialize
    @tipo = TIPO_IA
  end

  def joga(tabuleiro, cor_das_pecas)
    movimentos = EstadosSucessores.new({:cor_das_pecas => cor_das_pecas, :tabuleiro => tabuleiro}).movimento_com_mais_remocoes_possiveis
    # se eu tenho 2 movimentos com 2 remoções
    if movimentos.present? #se está presente, é pq tem algum com remoção (obrigatório) a realizar
      if movimentos.count == 1 #só tem um movimento com remoção a realizar, realizo ele
        movimentos.first.tabuleiro.atualiza_contadores(movimentos.first)
        return [movimentos.first.tabuleiro]
      elsif movimentos.count > 1 #se tem mais de um movimento possível com o mesmo número de remoções
        tabuleiros = []
        movimentos.each do |movimento|
          tabuleiros << pega_tabuleiros_ao_final_dos_movimentos([movimento])
        end
      end
    else # para quando não houver remoção a ser realizada, pega todas as peças e seus movimentos válidos
      tabuleiros = []
      casas_com_pecas_por_cor = tabuleiro.pega_casas_com_pecas_por_cor(cor_das_pecas)
      casas_com_pecas_por_cor.each do |casa|
        movimentos = movimentos_validos_por_peca(casa, tabuleiro) #pega todos os movimentos válidos
        movimentos.each do |movimento| #mapeia pegando o primeiro movimento e o estado do tabuleiro após ele ser realizado
          movimento.tabuleiro.atualiza_contadores(movimento)
          tabuleiros << movimento.tabuleiro
        end
      end
    end
    tabuleiros.flatten
  end

  def min_max_decision(tabuleiro)
    movimentos = EstadosSucessores.new({:cor_das_pecas => cor_das_pecas, :tabuleiro => tabuleiro}).movimento_com_mais_remocoes_possiveis
    if movimentos.present? #se está presente, é pq tem algum com remoção (obrigatório) a realizar
      sequencias_de_movimentos = []
      movimentos.each do |movimento|
        pega_sequencias_do_movimento(movimento).each do |sequencia_de_movimentos|
          sequencias_de_movimentos << sequencia_de_movimentos
          sequencia_de_movimentos.each do |movimento|
            movimento.tabuleiro.atualiza_contadores(movimento)
          end
        end
      end
      melhor_sequencia = sequencias_de_movimentos.min_by { |array_de_movimentos| min_value(array_de_movimentos.last.tabuleiro, 0) }
      return {:movimentos => melhor_sequencia, :tabuleiro => melhor_sequencia.last.tabuleiro}
    else # para quando não houver remoção a ser realizada, pega todas as peças e seus movimentos válidos
      tabuleiros_movimentos = []
      casas_com_pecas_por_cor = tabuleiro.pega_casas_com_pecas_por_cor(cor_das_pecas)
      casas_com_pecas_por_cor.each do |casa|
        movimentos_validos_por_peca(casa, tabuleiro).each do |movimento| #mapeia pegando o primeiro movimento e o estado do tabuleiro após ele ser realizado
          tabuleiros_movimentos << {:movimento => movimento, :tabuleiro => movimento.tabuleiro}
          movimento.tabuleiro.atualiza_contadores(movimento)
        end
      end
      melhor_par_tabuleiro_movimento = tabuleiros_movimentos.min_by { |tabuleiro_movimento| min_value(tabuleiro_movimento[:tabuleiro], 0) }
      return {:movimentos => [melhor_par_tabuleiro_movimento[:movimento]], :tabuleiro => melhor_par_tabuleiro_movimento[:tabuleiro]}
    end
  end

  def max_value(tabuleiro, profundidade)
    if profundidade >= PROFUNDIDADE_MAXIMA || tabuleiro.acabou?[:resposta] == true
      return Heuristica.new(@cor_das_pecas).calcula_heuristica(tabuleiro)
    else
      v = Float::MIN
      joga(tabuleiro, @cor_das_pecas).each do |tabuleiro|
        v = [v, min_value(tabuleiro, profundidade += 1)].max
      end
      return v
    end
  end

  def min_value(tabuleiro, profundidade)
    if profundidade >= PROFUNDIDADE_MAXIMA || tabuleiro.acabou?[:resposta] == true
      return Heuristica.new(Cor.contrario_de(@cor_das_pecas)).calcula_heuristica(tabuleiro)
    else
      v = Float::MAX
      joga(tabuleiro, Cor.contrario_de(@cor_das_pecas)).each do |tabuleiro|
        v = [v, max_value(tabuleiro, profundidade += 1)].min
      end
      return v
    end
  end


end
