require 'rails_helper'

RSpec.describe Movimento, type: :model do

  describe 'validações' do
    context 'não deve adicionar erros se o movimento for dentro dos limites' do
      it 'de 0,0 para 1,1' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 0, :y => 0),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 1, :y => 1)})
        expect(movimento.errors.any?).to be true
      end

      it 'de 8,2 para 2,8' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 8, :y => 2),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 2, :y => 8)})
        expect(movimento.errors.any?).to be true
      end

    end

    context 'deve adicionar erros se o movimento for fora dos limites' do
      it 'de 1,4 para 10,4' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 4),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 10, :y => 4)})
        expect(movimento.errors[:limites].any?).to be true
      end


      it 'de 1,4 para 4,10' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 4),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 4, :y => 10)})
        expect(movimento.errors[:limites].any?).to be true
      end

    end

    context 'adiciona erros se a casa inicial for igual a casa destino' do
      it 'de 1,4 para 1,4' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 4),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 1, :y => 4)})
        expect(movimento.errors[:posicoes_sao_iguais].any?).to be true
      end

      it 'de 10,4 para 1,4' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 2, :y => 4),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 1, :y => 3)})
        expect(movimento.errors[:posicoes_sao_iguais].any?).to be false
      end

    end

  end

  describe 'eh_em_diagonal?' do

    context 'deve retornar true se o movimento for em diagonal' do
      it 'de 0,0 para 1,1' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 0, :y => 0),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 1, :y => 1)})
        expect(movimento.eh_em_diagonal?).to be true
      end

      it 'de 8,2 para 2,8' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 8, :y => 2),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 2, :y => 8)})
        expect(movimento.eh_em_diagonal?).to be true
      end

    end

    context 'deve retornar false se o movimento não for em diagonal' do
      it 'de 1,4 para 5,4' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 4),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 4)})
        expect(movimento.eh_em_diagonal?).to be false
      end

      it 'de 1,1 para 1,5' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 1),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 1, :y => 5)})
        expect(movimento.eh_em_diagonal?).to be false
      end

      it 'de 1,1 para 4,5' do
        movimento = Movimento.new({:tabuleiro => Tabuleiro.new(Cor::BRANCA),
                                   :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 1),
                                   :posicao_destino => PosicaoTabuleiro.new(:x => 4, :y => 5)})
        expect(movimento.eh_em_diagonal?).to be false
      end

    end

  end


  describe 'deslocamento_vertical' do
    context 'peça deslocou verticalmente' do
      it 'deverá retornar valor do deslocamento UMA POSIÇÃO' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 0, :y => 0})
        posicao_destino = PosicaoTabuleiro.new({:x => 0, :y => 1})
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        movimento.deslocamento_vertical.should eql 1
      end
    end

  end

  describe 'deslocamento_horizontal' do
    context 'peça deslocou de 0,0 para 1,0' do
      it 'deverá retornar 1' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 0, :y => 0})
        posicao_destino = PosicaoTabuleiro.new({:x => 1, :y => 0})
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        movimento.deslocamento_horizontal.should eql 1
      end
    end

  end

  describe 'posicoes_da_diagonal' do

    context 'de baixo para cima' do
      it '0,0 para 1,1' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 0, :y => 0})
        posicao_destino = PosicaoTabuleiro.new({:x => 1, :y => 1})
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        expect(movimento.posicoes_da_diagonal).to eq([posicao_destino])
      end

      it '0,0 para 4,4' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 0, :y => 0})
        posicao_destino = PosicaoTabuleiro.new({:x => 4, :y => 4})
        oraculo = []
        for i in 1..4 do
          oraculo << PosicaoTabuleiro.new({:x => i, :y => i})
        end
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        expect(movimento.posicoes_da_diagonal).to eq(oraculo)
      end
    end

    context 'de cima para baixo' do
      it '7,7 para 1,1' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 7, :y => 7})
        posicao_destino = PosicaoTabuleiro.new({:x => 1, :y => 1})
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        oraculo = []
        6.downto(1) do |i|
          oraculo << PosicaoTabuleiro.new({:x => i, :y => i})
        end
        expect(movimento.posicoes_da_diagonal).to eq(oraculo)
      end

      it '1,5 para 3,3' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        posicao_inicial = PosicaoTabuleiro.new({:x => 1, :y => 5})
        posicao_destino = PosicaoTabuleiro.new({:x => 3, :y => 3})
        movimento = Movimento.new({:tabuleiro => tabuleiro, :posicao_destino => posicao_destino,
                                   :posicao_inicial => posicao_inicial})
        oraculo = [PosicaoTabuleiro.new({:x => 2, :y => 4}), PosicaoTabuleiro.new({:x => 3, :y => 3})]
        expect(movimento.posicoes_da_diagonal).to eq(oraculo)
      end


    end
  end


end
