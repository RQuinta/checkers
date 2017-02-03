module MovimentosHelper

  def movimento_com_mais_remocoes_por_peca(casa, tabuleiro, cor_das_pecas)
    movimentos = movimentos_com_remocao_validos_por_peca(casa, tabuleiro, cor_das_pecas)
    if movimentos.present?
      pega_maior_movimento(movimentos)
    end
  end

  def pega_tabuleiros_ao_final_dos_movimentos(movimentos)
    tabuleiros = []
    movimentos = Marshal.load(Marshal.dump(movimentos))
    movimentos.each do |movimento|
      if movimento.movimentos_com_remocao_a_realizar.any?
        movimento.tabuleiro.atualiza_contadores(movimento)
        movimento = movimento.movimentos_com_remocao_a_realizar
        tabuleiros << pega_tabuleiros_ao_final_dos_movimentos(movimento)
      else
        tabuleiros << movimento.tabuleiro
        movimento.tabuleiro.atualiza_contadores(movimento)
      end
    end
    tabuleiros.flatten
  end


  #[  [M(3,3 para 5,5), M(5,5 para 4,6)], [M(3,3 para 5,5), M(5,5 para 3,7)] ] EXEMPLO DE RETORNO
  def pega_sequencias_do_movimento(movimento)
    if movimento.movimentos_com_remocao_a_realizar.empty?
      return [[movimento]]
    else
      retorno = []
      movimento.movimentos_com_remocao_a_realizar.each do |movimento_com_remocao|
        retorno << [movimento] + [pega_sequencias_do_movimento(movimento_com_remocao)].flatten
      end
    end
    return retorno
  end

  def movimentos_com_remocao_validos_por_peca(casa, tabuleiro, cor_das_pecas)
    movimentos = []
    if casa.peca.tipo == Peao::TIPO_PEAO
      movimentos << cria_movimento_peao(casa, 2, 2, tabuleiro) #direita, cima
      movimentos << cria_movimento_peao(casa, -2, 2, tabuleiro) #esquerda, cima
      movimentos << cria_movimento_peao(casa, 2, -2, tabuleiro) #direita, baixo
      movimentos << cria_movimento_peao(casa, -2, -2, tabuleiro) #esquerda, baixo
    else
      posicoes = posicoes_destino_com_remocao_dama(casa.posicao, tabuleiro, cor_das_pecas)
      posicoes.each do |posicao|
        movimentos << MovimentoDama.new({:tabuleiro => Marshal.load(Marshal.dump(tabuleiro)),
                                         :posicao_inicial => casa.posicao,
                                         :posicao_destino => posicao})
      end
    end
    movimentos.select! { |movimento| movimento.errors.empty? }
    movimentos.compact
  end

  def movimentos_validos_por_peca(casa, tabuleiro)
    movimentos = []
    if casa.peca.tipo == Peao::TIPO_PEAO
      movimentos << cria_movimento_peao(casa, 1, 1, tabuleiro) #direita, cima
      movimentos << cria_movimento_peao(casa, -1, 1, tabuleiro) #esquerda, cima
      movimentos << cria_movimento_peao(casa, 1, -1, tabuleiro) #direita, baixo
      movimentos << cria_movimento_peao(casa, -1, -1, tabuleiro) #esquerda, baixo
    else
      posicoes = posicoes_destino_possiveis_dama(casa.posicao, tabuleiro)
      posicoes.flatten.each do |posicao|
        movimentos << MovimentoDama.new({:tabuleiro => Marshal.load(Marshal.dump(tabuleiro)),
                                         :posicao_inicial => casa.posicao,
                                         :posicao_destino => posicao})
      end
    end
    movimentos.select! { |movimento| movimento.errors.empty? }
    movimentos.compact
  end

  def posicoes_destino_possiveis_dama(posicao_inicial, tabuleiro)
    posicoes = []
    posicoes << diagonais_dama_validas(posicao_inicial, 1, 1, tabuleiro) #direita, cima
    posicoes << diagonais_dama_validas(posicao_inicial, -1, -1, tabuleiro) #esquerda, cima
    posicoes << diagonais_dama_validas(posicao_inicial, 1, -1, tabuleiro) #direita, baixo
    posicoes << diagonais_dama_validas(posicao_inicial, -1, 1, tabuleiro) #esquerda, baixo
    posicoes.compact #tira os nulos do array
  end

  def diagonais_dama_validas(posicao_inicial, deslocamento_x, deslocamento_y, tabuleiro)
    posicoes = []
    posicao_atual = posicao_inicial.dup
    loop do
      proxima_casa = tabuleiro.matriz[posicao_atual.x += deslocamento_x, posicao_atual.y += deslocamento_y]
      if proxima_casa.present?
        if proxima_casa.peca.nil?
          if posicao_atual.valid?
            posicoes << posicao_atual.dup
          end
        end
      else
        break
      end
    end
    return posicoes
  end

  def pega_maior_movimento(movimentos)
    movimentos_possiveis = movimentos.compact.flatten
    if movimentos_possiveis.any?
      max = movimentos_possiveis.max_by { |movimento| movimento.qtd_remocoes_ainda_a_realizar }.qtd_remocoes_ainda_a_realizar
      if max.zero? #se nenhum tem remoção a realizar depois da primeira remoção
        movimentos_possiveis.select { |movimento| movimento.eh_com_remocao } #retorna todos que tem remoção
      else
        movimentos_possiveis.select { |movimento| movimento.qtd_remocoes_ainda_a_realizar == max } #retorna todos que tem o maior número de remoções
      end
    end
  end

  def cria_movimento_peao(casa, deslocamento_x, deslocamento_y, tabuleiro) #criar um helper de movimento para fazer isso
    MovimentoPeao.new({:tabuleiro => Marshal.load(Marshal.dump(tabuleiro)),
                       :posicao_inicial => casa.posicao,
                       :posicao_destino => PosicaoTabuleiro.new(:x => casa.posicao.x + deslocamento_x, :y => casa.posicao.y + deslocamento_y)})
  end

  def posicoes_destino_com_remocao_dama(posicao_inicial, tabuleiro, cor_das_pecas)
    posicoes = []
    posicoes << primeira_diagonal_com_remocao_dama(posicao_inicial, 1, 1, tabuleiro, cor_das_pecas) #direita, cima
    posicoes << primeira_diagonal_com_remocao_dama(posicao_inicial, -1, -1, tabuleiro, cor_das_pecas) #esquerda, cima
    posicoes << primeira_diagonal_com_remocao_dama(posicao_inicial, 1, -1, tabuleiro, cor_das_pecas) #direita, baixo
    posicoes << primeira_diagonal_com_remocao_dama(posicao_inicial, -1, 1, tabuleiro, cor_das_pecas) #esquerda, baixo
    posicoes.compact.flatten #tira os nulos do array
  end

  def primeira_diagonal_com_remocao_dama(posicao_inicial, deslocamento_x, deslocamento_y, tabuleiro, cor_das_pecas)
    posicao_atual = posicao_inicial.dup
    loop do
      proxima_casa = tabuleiro.matriz[posicao_atual.x += deslocamento_x, posicao_atual.y += deslocamento_y]
      if proxima_casa.present?
        if proxima_casa.peca.present?
          if proxima_casa.peca.cor != cor_das_pecas
            retorno = []
            loop do #faz loop para pegar todas as posições depois da peça que vai comer
              casa_depois_da_peca_a_comer = tabuleiro.matriz[posicao_atual.x += deslocamento_x, posicao_atual.y += deslocamento_y]
              if casa_depois_da_peca_a_comer.present?
                if !casa_depois_da_peca_a_comer.try(:peca).present?
                  retorno << PosicaoTabuleiro.new(:x => posicao_atual.x, :y => posicao_atual.y)
                else
                  return retorno
                end
              else
                return retorno
              end
            end
          elsif proxima_casa.peca.cor == cor_das_pecas # se encontrou uma peça do outro time ou saiu dos limites do tabuleiro
            break
          end
        end
      else
        break
      end
    end
  end


end
