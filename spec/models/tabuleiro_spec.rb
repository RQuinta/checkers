require 'rails_helper'

RSpec.describe Tabuleiro, type: :model do

  describe 'existe_peca_na_posicao?' do
    context 'tem peça na posição' do
      it 'deverá retornar true' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[0, 0].peca = Peao.new({:cor => Cor::BRANCA})
        tabuleiro.existe_peca_na_posicao?(PosicaoTabuleiro.new({:x => 0, :y => 0})).should eql true
      end
    end

    context 'nao tem peça na posição' do
      it 'deverá retornar false' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[0, 0].peca = nil
        tabuleiro.existe_peca_na_posicao?(PosicaoTabuleiro.new({:x => 0, :y => 0})).should eql false
      end
    end

  end


  describe 'remove_peca' do
    context 'com peça na posição' do
      it 'deverá retornar true' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[0, 0].peca = Peao.new({:cor => Cor::BRANCA})
        tabuleiro.remove_peca(PosicaoTabuleiro.new({:x => 0, :y => 0})).should eql true
      end
    end

    context 'sem peça na posição' do
      it 'deverá retornar false' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[0, 0].peca = nil
        tabuleiro.remove_peca(PosicaoTabuleiro.new({:x => 0, :y => 0})).should eql false
      end
    end

  end


end
