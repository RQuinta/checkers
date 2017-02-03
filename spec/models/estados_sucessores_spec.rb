require 'rails_helper'

RSpec.describe EstadosSucessores, type: :model do

  describe 'peao' do

    context 'tabuleiro com maior numero de remoções possíveis em uma peça com uma remoção a ser feita' do
      it 'peão 1,3 para 3,5' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[1, 3].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[2, 4].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[3, 5].peca = nil
        encontrador = EstadosSucessores.new({:cor_das_pecas => Cor::BRANCA, :tabuleiro => tabuleiro})
        expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_inicial).to eq(PosicaoTabuleiro.new(:x => 1, :y => 3))
        expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_destino).to eq(PosicaoTabuleiro.new(:x => 3, :y => 5))
      end

      it 'dama 1,3 para 3,5' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[1, 3].peca = Dama.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[2, 4].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[3, 5].peca = nil
        encontrador = EstadosSucessores.new({:cor_das_pecas => Cor::BRANCA, :tabuleiro => tabuleiro})
        expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_inicial).to eq(PosicaoTabuleiro.new(:x => 1, :y => 3))
        expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_destino).to eq(PosicaoTabuleiro.new(:x => 3, :y => 5))
      end

    end

  end

  describe 'tabuleiro inicial' do

    it 'dama 1,3 para 3,5' do
      tabuleiro = Tabuleiro.new(Cor::BRANCA)
      tabuleiro.matriz[1, 3].peca = Dama.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
      tabuleiro.matriz[2, 4].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
      tabuleiro.matriz[3, 5].peca = nil
      encontrador = EstadosSucessores.new({:cor_das_pecas => Cor::BRANCA, :tabuleiro => tabuleiro})
      expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_inicial).to eq(PosicaoTabuleiro.new(:x => 1, :y => 3))
      expect(encontrador.movimento_com_mais_remocoes_possiveis.first.posicao_destino).to eq(PosicaoTabuleiro.new(:x => 3, :y => 5))
    end

  end


end