class CasaTabuleiro

  attr_reader :cor, :posicao
  attr_accessor :peca

  def initialize(params)
    @cor = params[:cor]
    @peca = params[:peca]
    @posicao = params[:posicao]
  end

end