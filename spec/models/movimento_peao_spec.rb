require 'rails_helper'

RSpec.describe MovimentoPeao, type: :model do

  describe 'comer' do
    context 'deve comer se tiver uma peça do outro time à frente e uma casa vazia depois' do
      it '2,2 para 4,4' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[3, 3].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 2, :y => 2),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 4, :y => 4)})
        expect(movimento.errors.full_messages.any?).to be false
        expect(tabuleiro.matriz[3, 3].peca).to be nil
        expect(tabuleiro.matriz[4, 4].peca.cor).to be Cor::BRANCA
      end
    end

    context 'não deve comer se tiver uma peça do mesmo time à frente e uma casa vazia depois' do
      it 'de 2,2 para 4,4' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[3, 3].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 2, :y => 2),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 4, :y => 4)})
        expect(movimento.errors[:peca_do_mesmo_time_no_caminho].any?).to be true
      end
    end

  end

  describe 'vira dama' do
    context 'deverá virar dama se chegar do outro lado' do
      it '3,5 para 1,7' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[1, 5].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[3, 7].peca = nil
        MovimentoPeao.new({:tabuleiro => tabuleiro,
                           :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 5),
                           :posicao_destino => PosicaoTabuleiro.new(:x => 3, :y => 7)})
        expect(tabuleiro.matriz[3, 7].peca.tipo).to be Dama::TIPO_DAMA
      end
    end

    context 'nao devera virar dama se passar pela última casa do outro lado mas ainda tiver movimento a fazer' do
      it '1,5 para 3,7' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        tabuleiro.matriz[1, 5].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[5, 5].peca = nil
        tabuleiro.matriz[3, 7].peca = nil
        MovimentoPeao.new({:tabuleiro => tabuleiro,
                           :posicao_inicial => PosicaoTabuleiro.new(:x => 1, :y => 5),
                           :posicao_destino => PosicaoTabuleiro.new(:x => 3, :y => 7)})
        expect(tabuleiro.matriz[3, 7].peca.tipo).to be Peao::TIPO_PEAO
      end
    end
  end

  describe 'movimento com mais de uma remoção' do
    context 'deverá retornar um array avisando que ainda há uma remoção a fazer' do
      it '7,5 para 5,7' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[7, 5].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[4, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 7, :y => 5),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 7)})
        expect(movimento.qtd_remocoes_ainda_a_realizar).to eq(1)
      end
    end
  end

  describe 'movimento com uma remoção' do
    context 'deverá retornar um array avisando não há nenhuma remoção a fazer' do
      it '7,7 para 5,7' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[7, 5].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 7, :y => 5),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 7)})
        expect(movimento.qtd_remocoes_ainda_a_realizar).to eq(0)
        expect(movimento.movimentos_com_remocao_a_realizar.count).to eq(0)
      end
    end
  end

  describe 'teste que bugou na tela' do
    context 'a cor não deveria mudar' do
      it '' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        peca_preta = tabuleiro.matriz[7, 7].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[6, 6].peca = nil
        peca_branca = tabuleiro.matriz[0, 0].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 0, :y => 0),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 7, :y => 7)})
        expect(tabuleiro.matriz[7, 7].peca).to eq(peca_preta)
      end
    end

    context 'escolha entre dois movimentos depois de fazer uma remoção' do
      it '' do
        tabuleiro = Tabuleiro.new(Cor::BRANCA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[7, 3].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[6, 4].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[4, 6].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        movimento = MovimentoPeao.new({:tabuleiro => tabuleiro,
                                       :posicao_inicial => PosicaoTabuleiro.new(:x => 7, :y => 3),
                                       :posicao_destino => PosicaoTabuleiro.new(:x => 5, :y => 5)})
        expect(movimento.qtd_remocoes_ainda_a_realizar).to eq(1)
        expect(movimento.movimentos_com_remocao_a_realizar.count).to eq(2)
      end
    end

  end


end
