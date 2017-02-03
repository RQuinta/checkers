RSpec.describe Heuristica, type: :model do

  describe 'testes de heurística' do

    context 'tabuleiro inicial' do
      it 'deveria retornar 0' do
        partida = Partida.new({:jogador1 => Humano::TIPO_HUMANO, :jogador2 => IA::TIPO_IA})
        valor_heuristica = Heuristica.new(Cor::BRANCA).calcula_heuristica(partida.tabuleiro)
        expect(valor_heuristica).to eq(0.0)
      end
    end

    context 'tabuleiro com pecas na 0,0 1,1 0,2 e uma peca do adversario na 6,6' do
      it 'deveria retornar 8' do
        tabuleiro = Tabuleiro.new Cor::PRETA
        ia = IA.new()
        ia.set_cor_de_suas_pecas(Cor::PRETA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[0, 0].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[1, 1].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[0, 2].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::CIMA})
        expect(Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)).to eq(10.5)
      end
    end

    context 'tabuleiro com pecas na 2,2 3,3 4,2 e uma peca do adversario na 6,6' do
      it 'deveria retornar 8' do
        tabuleiro = Tabuleiro.new Cor::PRETA
        ia = IA.new()
        ia.set_cor_de_suas_pecas(Cor::PRETA)
        for i in 0..7
          for j in 0..7
            tabuleiro.matriz[i, j].peca = nil
          end
        end
        tabuleiro.matriz[2, 2].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[3, 3].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[4, 2].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::CIMA})
        tabuleiro.matriz[6, 6].peca = Peao.new({:cor => Cor::BRANCA, :lado_inicial => Lado::BAIXO})
        expect(Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)).to eq(8.0)
      end
    end

    context 'tabuleiro inicial com a peca 1,5 removida' do
      it 'deveria retornar 3' do
        tabuleiro = Tabuleiro.new Cor::PRETA
        ia = IA.new()
        ia.set_cor_de_suas_pecas(Cor::PRETA)
        tabuleiro.matriz[2, 2].peca = nil
        expect(Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)).to eq(-5.0)
      end
    end


    context 'tabuleiro inicial com uma dama na 1,3' do
      it 'deveria retornar 11' do
        tabuleiro = Tabuleiro.new Cor::PRETA
        ia = IA.new()
        ia.set_cor_de_suas_pecas(Cor::PRETA)
        tabuleiro.matriz[1, 3].peca = Dama.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        expect(Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)).to eq(11.0)
      end
    end

    context 'dois tabuleiros um com peça andando pro centro e outro pro canto' do
      it 'a heurística do que tá andando pro canto deverá ser maior' do
        tabuleiro = Tabuleiro.new Cor::PRETA
        tabuleiro.matriz[1, 3].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        h1 = Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)
        tabuleiro = Tabuleiro.new Cor::PRETA
        tabuleiro.matriz[7, 3].peca = Peao.new({:cor => Cor::PRETA, :lado_inicial => Lado::BAIXO})
        h2 = Heuristica.new(Cor::PRETA).calcula_heuristica(tabuleiro)
        expect(h2 > h1).to eq(true)
      end
    end

  end
end