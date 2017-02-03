class Tabuleiro

  include ActiveModel::Model
  include MovimentosHelper
  attr_accessor :matriz

  LIMITES = (0..7)

  def initialize(cor_que_fica_embaixo)
    cria_matriz(cor_que_fica_embaixo)
    @qtd_jogadas_de_damas_sem_captura = 0
    @qtd_jogadas_sem_remocao = 0
  end


  def acabou?
    return empatou if empatou[:resposta]
    return tem_vencedor if tem_vencedor[:resposta]
    return {:resposta => false}
  end

  def tem_vencedor
    jogador_um_tem_peca = pega_pecas_por_cor(Cor::BRANCA).any? #boolean
    jogador_dois_tem_peca = pega_pecas_por_cor(Cor::PRETA).any? #boolean
    if jogador_um_tem_peca && jogador_dois_tem_peca
      if !jogador_tem_jogadas?(Cor::BRANCA)
        return {:resposta => true, :quem_ganhou => Cor::PRETA}
      elsif !jogador_tem_jogadas?(Cor::PRETA)
        return {:resposta => true, :quem_ganhou => Cor::BRANCA}
      end
    else
      return {:resposta => true, :quem_ganhou => Cor::BRANCA} if jogador_um_tem_peca
      return {:resposta => true, :quem_ganhou => Cor::PRETA} if jogador_dois_tem_peca
    end
    return {:resposta => false}
  end

  def atualiza_contadores(movimento)
    atualiza_qtd_jogadas_sem_remocao(movimento)
    atualiza_qtd_jogadas_de_damas_sem_captura(movimento)
  end

  def atualiza_qtd_jogadas_sem_remocao(movimento)
    if movimento.eh_com_remocao
      @qtd_jogadas_sem_remocao = 0
    else
      @qtd_jogadas_sem_remocao += 1
    end
  end

  def atualiza_qtd_jogadas_de_damas_sem_captura(movimento)
    if movimento.class == MovimentoDama && movimento.eh_com_remocao == false
      @qtd_jogadas_de_damas_sem_captura += 1
    else
      @qtd_jogadas_de_damas_sem_captura = 0
    end
  end

  #20 lances sucessivos de damas sem captura || 5 jogadas em casos especiais
  def empatou
    if @qtd_jogadas_de_damas_sem_captura == 20 || empatada_por_5_jogadas_casos_especiais?
      return {:resposta => true, :quem_ganhou => nil}
    else
      return {:resposta => false}
    end
  end

  def jogador_tem_jogadas?(cor)
    pega_casas_com_pecas_por_cor(cor).each do |casa|
      return true if movimentos_validos_por_peca(casa, self).any?
    end
  end

  def empatada_por_5_jogadas_casos_especiais?
    if @qtd_jogadas_sem_remocao == 5
      count_hash = conta_pecas_por_cor_e_tipo
      qtd_damas_brancas_e_pretas = count_hash.map { |cor, valor| valor[:qtd_damas] }.sort
      qtd_peoes_brancas_e_pretas = count_hash.map { |cor, valor| valor[:qtd_peoes] }.sort
      if count_hash[:pretas][:qtd_damas] == 2 && count_hash[:brancas][:qtd_damas] == 2
        true
      elsif count_hash[:pretas][:qtd_damas] == 1 && count_hash[:brancas][:qtd_damas] == 1
        true
      elsif qtd_damas_brancas_e_pretas == [1, 2] # se tem 1 dama de um lado e 2 do outro
        true
      elsif qtd_damas_brancas_e_pretas == [1, 1] && qtd_peoes_brancas_e_pretas == [0, 1] #uma dama contra uma dama e uma pedra
        true
      elsif qtd_damas_brancas_e_pretas == [1, 2] && qtd_peoes_brancas_e_pretas == [0, 1] #duas damas contra uma dama e uma pedra
        true
      end
    end
    false
  end

  def conta_pecas_por_cor_e_tipo
    retorno = Hash.new { |hash, key| hash[key] = {:qtd_peoes => 0, :qtd_damas => 0} }
    pega_pecas.each do |peca|
      if peca.cor == Cor::BRANCA
        if peca.tipo == Peao::TIPO_PEAO
          retorno[:brancas][:qtd_peoes] += 1
        elsif peca.tipo == Dama::TIPO_DAMA
          retorno[:brancas][:qtd_damas] += 1
        end
      else
        if peca.tipo == Peao::TIPO_PEAO
          retorno[:pretas][:qtd_peoes] += 1
        elsif peca.tipo == Dama::TIPO_DAMA
          retorno[:pretas][:qtd_damas] += 1
        end
      end
    end
    retorno
  end

  def pega_casas_com_pecas_por_cor(cor)
    casas = []
    for i in 0..7
      for j in 0..7
        casas << @matriz[i, j] if @matriz[i, j].peca.try(:cor) == cor
      end
    end
    casas
  end

  def pega_pecas
    pecas = []
    for i in 0..7
      for j in 0..7
        pecas << @matriz[i, j].peca if @matriz[i, j].peca != nil
      end
    end
    pecas
  end

  def pega_pecas_por_cor(cor)
    pecas = []
    for i in 0..7
      for j in 0..7
        pecas << @matriz[i, j].peca if @matriz[i, j].try(:peca).try(:cor) == cor
      end
    end
    pecas
  end

  def imprime
    for i in 0..7
      @matriz.row_vectors[i].each do |elemento|
        print " #{elemento.peca.try(:cor)|| 'VAZIO'} | "
      end
      print "\n"
    end
    # print " #{@matriz[i, j].peca.try(:cor)|| 'VAZIO'} | "
    # end
    # print "\n"
    # end
    return nil
  end

  def get_casa(posicao)
    @matriz[posicao.x, posicao.y]
  end

  def get_peca(posicao)
    @matriz[posicao.x, posicao.y].try(:peca)
  end

  def remove_peca(posicao)
    return false if @matriz[posicao.x, posicao.y].peca == nil
    @matriz[posicao.x, posicao.y].peca = nil
    true
  end

  def existe_peca_na_posicao?(posicao)
    @matriz[posicao.x, posicao.y].try(:peca) != nil
  end

  def movimenta_peca(params)
    posicao_inicial = params[:posicao_inicial]
    posicao_destino = params[:posicao_destino]
    peca = get_peca(posicao_inicial)
    remove_peca(posicao_inicial)
    get_casa(posicao_destino).peca = peca
  end

  private

  def cria_matriz(cor_que_fica_embaixo)
    @matriz = Matrix.build(8, 8) do |linha, coluna|
      if linha % 2 != coluna % 2
        CasaTabuleiro.new({:cor => Cor::BRANCA, :peca => nil, :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})}) #fundo branco, sem peça
      else #fundo preto
        if coluna == 0 || coluna == 1 || coluna == 2
          if cor_que_fica_embaixo == Cor::PRETA
            CasaTabuleiro.new({:cor => Cor::PRETA, :peca => Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO}), :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})})
          else
            CasaTabuleiro.new({:cor => Cor::PRETA, :peca => Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO}), :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})})
          end
        elsif coluna == 5 || coluna == 6 || coluna == 7
          if cor_que_fica_embaixo == Cor::PRETA
            CasaTabuleiro.new({:cor => Cor::PRETA, :peca => Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::CIMA}), :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})})
          else
            CasaTabuleiro.new({:cor => Cor::PRETA, :peca => Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA}), :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})})
          end
        else
          CasaTabuleiro.new({:cor => Cor::PRETA, :peca => nil, :posicao => PosicaoTabuleiro.new({:x => linha, :y => coluna})}) #fundo preto sem peça
        end
      end
    end

  end


end