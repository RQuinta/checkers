require 'rails_helper'

RSpec.describe MovimentoDama, type: :model do

  describe 'movimento com mais de uma remoção' do
    context 'deverá retornar um array avisando que ainda há uma remoção a fazer' do
      it '1,1 para 3,3' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[7, 5].peca = Dama.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[4, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoDama.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 7, :y => 5),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 7)})
        expect(movimento.qtd_remocoes_ainda_a_realizar).to eq(1)
        expect(movimento.movimentos_com_remocao_a_realizar.count).to eq(1)
      end
    end
  end

  describe 'movimento com uma remoção' do
    context 'deverá retornar um array avisando não há nenhuma remoção a fazer' do
      it '1,1 para 3,3' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[7, 5].peca = Dama.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoDama.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 7, :y => 5),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 7)})
        expect(movimento.qtd_remocoes_ainda_a_realizar).to eq(0)
        expect(movimento.movimentos_com_remocao_a_realizar.count).to eq(0)
      end
    end
  end

end