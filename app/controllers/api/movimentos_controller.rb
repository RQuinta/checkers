class Api::MovimentosController < ApplicationController

  respond_to :json

  def create
    params = movimento_params
    partida = BancoPartida.instance.pega_partida(params['partida_identificador'])
    if params[:tipo_jogador] != IA::TIPO_IA
      params['posicao_inicial'] = PosicaoTabuleiro.new(:x => params['posicao_inicial']['x'], :y => movimento_params['posicao_inicial']['y'])
      params['posicao_destino'] = PosicaoTabuleiro.new(:x => params['posicao_destino']['x'], :y => movimento_params['posicao_destino']['y'])
      resposta = partida.valida_movimentacao(params)
    else
      resposta = partida.pega_movimento_ia
    end
    render json: resposta
  end


  private


  def movimento_params
    params.require(:movimento).permit(:partida_identificador,
                                      :tipo_jogador,
                                      :posicao_inicial => [:x, :y],
                                      :posicao_destino => [:x, :y],
                                      :movimentos_com_remocao_a_realizar => [{}])
  end

end
