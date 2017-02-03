function Tabuleiro(ValidacaoMovimento, Partida,$q) {
    var self = this;
    var letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    self.criaPartida = function (jogador1, jogador2) {
        return Partida.create({
            jogador1: jogador1, jogador2: jogador2
        }, function (tabuleiro) {
            for (var i = 1; i < 9; i++) { // as colunas
                for (var j = 0; j < 8; j++) { // as linhas
                    var posicao = tabuleiro.tabuleiro.matriz[i - 1][j];
                    if (posicao.peca === null) {
                        casa3 = document.getElementById(letras[i - 1] + (j + 1));
                        casa3.setAttribute('peça', '0');
                        //casa3.onclick = function () {
                        //    ValidacaoMovimento.move(this, this.getAttribute('peça'), tabuleiro);
                        //}
                    } else {
                        casa = document.getElementById(letras[i - 1] + (j + 1));
                        if (posicao.peca.cor == "BRANCA") {
                            casa.setAttribute('peça', 'BRANCA');
                            //casa.onclick = function () {
                            //    ValidacaoMovimento.move(this, this.getAttribute('peça'), tabuleiro);
                            //}
                            casa.style.backgroundImage = "url('pedra-azul.jpg')";
                        } else {
                            casa2 = document.getElementById(letras[i - 1] + (j + 1));
                            casa2.setAttribute('peça', 'PRETA');
                            casa2.style.backgroundImage = "url('pedra-verde.jpg')";
                            //casa2.onclick = function () {
                            //    ValidacaoMovimento.move(this, this.getAttribute('peça'), tabuleiro);
                            //}
                        }
                    }
                }
            }
        })
    }

    self.montaTabela = function () {
        var table = document.createElement("table");
        table.id = "tabuleiro";
        var div = document.getElementById("partida");
        for (var i = 8; i >= 1; i--) {
            var count = 1;
            var tr = document.createElement('tr');
            for (var j = 1; j < 9; j++) {
                var td = document.createElement('td');
                if (i % 2 != j % 2) {
                    td.className = "black";
                    td.id = letras[j - 1] + i;
                    count++;
                } else {
                    td.id = letras[j - 1] + i;
                    td.className = "white";
                }

                tr.appendChild(td);
            }
            table.appendChild(tr);
        }
        table.setAttribute("align", 'center');
        div.appendChild(table);
    }

    return self;
}