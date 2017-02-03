class Heuristica

  include MovimentosHelper

  def initialize(cor_das_pecas)
    @cor_das_pecas = cor_das_pecas
  end

  def calcula_heuristica(tabuleiro)
    calcula_heuristica_ia(tabuleiro) - calcula_heuristica_adversario(tabuleiro)
  end

  def calcula_heuristica_ia(tabuleiro)
    casas_tabuleiro_com_pecas = tabuleiro.pega_casas_com_pecas_por_cor(@cor_das_pecas)
    calcula_pontos_por_ameaca_de_outras_pecas(casas_tabuleiro_com_pecas, tabuleiro) +
        calcula_pontos_por_regra_da_cobertura_amiga(tabuleiro, @cor_das_pecas, casas_tabuleiro_com_pecas) +
        calcula_pontos_por_regra_da_cobertura_parede(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_tipo_e_quantidade_de_pecas(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_regra_vai_virar_dama(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_peca_protegendo_de_virar_dama(casas_tabuleiro_com_pecas)
  end

  def calcula_heuristica_adversario(tabuleiro)
    casas_tabuleiro_com_pecas = tabuleiro.pega_casas_com_pecas_por_cor(Cor.contrario_de(@cor_das_pecas))
    calcula_pontos_por_ameaca_de_outras_pecas(casas_tabuleiro_com_pecas, tabuleiro) +
        calcula_pontos_por_regra_da_cobertura_amiga(tabuleiro, Cor.contrario_de(@cor_das_pecas), casas_tabuleiro_com_pecas) +
        calcula_pontos_por_regra_da_cobertura_parede(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_tipo_e_quantidade_de_pecas(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_regra_vai_virar_dama(casas_tabuleiro_com_pecas) +
        calcula_pontos_por_peca_protegendo_de_virar_dama(casas_tabuleiro_com_pecas)
  end

  def calcula_pontos_por_peca_protegendo_de_virar_dama(casas_tabuleiro_com_pecas)
    pontos = 0
    lado = casas_tabuleiro_com_pecas.first.try(:lado_inicial)
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      if lado == Lado::CIMA
        if casa_tabuleiro_com_peca.posicao.y == 7
          pontos += 4
        end
      else
        if casa_tabuleiro_com_peca.posicao.y == 0
          pontos += 4
        end
      end
    }
    pontos
  end

  def calcula_pontos_por_tipo_e_quantidade_de_pecas(casas_tabuleiro_com_pecas)
    pontos = 0
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      if casa_tabuleiro_com_peca.peca.tipo == Peao::TIPO_PEAO
        pontos += 3
      elsif casa_tabuleiro_com_peca.peca.tipo == Dama::TIPO_DAMA
        pontos += 9
      end
    }
    pontos
  end

  def calcula_pontos_por_ameaca_de_outras_pecas(casas_tabuleiro_com_pecas, tabuleiro)
    pontos = 0
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      movimentos = movimentos_com_remocao_validos_por_peca(casa_tabuleiro_com_peca, tabuleiro, casa_tabuleiro_com_peca.peca.cor)
      # movimentos.select! { |movimento| movimento.eh_com_remocao }
      movimentos.each { |movimento|
        if tabuleiro.get_casa(movimento.posicao_da_peca_no_caminho).peca.tipo == Peao::TIPO_PEAO
          pontos += 2
        elsif tabuleiro.get_casa(movimento.posicao_da_peca_no_caminho).peca.tipo == Dama::TIPO_DAMA
          pontos += 6
        end
      }
    }
    pontos
  end

  def calcula_pontos_por_regra_da_cobertura_amiga(tabuleiro, cor_das_pecas, casas_tabuleiro_com_pecas)
    pontos = 0
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      diagonais = []
      posicao = casa_tabuleiro_com_peca.posicao
      diagonais << PosicaoTabuleiro.new({:x => posicao.x + 1, :y => posicao.y + 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x + 1, :y => posicao.y - 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x - 1, :y => posicao.y - 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x - 1, :y => posicao.y + 1})
      diagonais.keep_if { |diagonal| diagonal.valid? }
      diagonais.each do |posicao|
        pontos += 0.5 if tabuleiro.get_casa(posicao).try(:peca).try(:cor) == cor_das_pecas
      end
    }
    pontos
  end

  def calcula_pontos_por_regra_da_cobertura_parede(casas_tabuleiro_com_pecas)
    pontos = 0
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      diagonais = []
      posicao = casa_tabuleiro_com_peca.posicao
      diagonais << PosicaoTabuleiro.new({:x => posicao.x + 1, :y => posicao.y + 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x + 1, :y => posicao.y - 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x - 1, :y => posicao.y - 1})
      diagonais << PosicaoTabuleiro.new({:x => posicao.x - 1, :y => posicao.y + 1})
      diagonais.reject! { |diagonal| diagonal.valid? }
      pontos = diagonais.count * 0.5
    }
    pontos
  end


  def calcula_pontos_por_regra_vai_virar_dama(casas_tabuleiro_com_pecas)
    pontos = 0
    casas_tabuleiro_com_pecas.each { |casa_tabuleiro_com_peca|
      posicao = casa_tabuleiro_com_peca.posicao
      if casa_tabuleiro_com_peca.peca.lado_inicial == Lado::CIMA
        pontos += 6 if posicao.y == Tabuleiro::LIMITES.first
      else
        pontos += 6 if posicao.y == Tabuleiro::LIMITES.last
      end
    }
    pontos
  end

end