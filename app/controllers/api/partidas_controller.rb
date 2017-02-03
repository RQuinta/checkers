class Api::PartidasController < ApplicationController

  respond_to :json

  def create
    partida = Partida.new(partida_new_params)
    BancoPartida.instance.adiciona_partida(partida)
    respond_with :api, partida
  end

  def verifica_se_partida_acabou
    banco = BancoPartida.instance
    identificador_partida = Partida.verifica_se_partida_acabou_params[:identificador_partida]
    partida = banco.pega_partida(identificador_partida)
    retorno = partida.acabou?
    if retorno[:resposta] #se acabou
      banco.apaga_partida(identificador_partida)
    end
    render json: retorno
  end

  private

  def partida_new_params
    params.require(:partida).
        permit([:jogador1, :jogador2])
  end

  def verifica_se_partida_acabou_params
    params.require(:partida).permit([:identificador_partida])
  end

end
