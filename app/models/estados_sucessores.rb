class EstadosSucessores

  include MovimentosHelper

  def initialize(params)
    @cor_das_pecas = params[:cor_das_pecas]
    @tabuleiro = Marshal.load(Marshal.dump(params[:tabuleiro])) #cria outra referência para o tabuleiro e seus objetos internos
  end

  def movimento_com_mais_remocoes_possiveis
    movimentos_possiveis = []
    @tabuleiro.pega_casas_com_pecas_por_cor(@cor_das_pecas).each do |casa|
      movimentos_possiveis << movimento_com_mais_remocoes_por_peca(casa, @tabuleiro, @cor_das_pecas) if casa.peca != nil
    end
    pega_maior_movimento(movimentos_possiveis)
  end

end


