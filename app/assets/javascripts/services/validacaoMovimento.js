function validacaoMovimento(Movimento, Partida, $q,$modal) {
    var self = this;
    var letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    var posicaoInicial = {
        x: null,
        y: null
    };
    var posicaoFinal = {
        x: null,
        y: null
    };
    var valorCasa = 5;
    var vez = "BRANCA";
    var erros = "";
    var movimentosARealizar = null;
    self.validaMovimento = function (identificador, posicaoInicial, posicaoFinal, movimentosARealizar) {
        var deferred = $q.defer();
        return Movimento.create({
                partida_identificador: identificador,
                posicao_inicial: posicaoInicial,
                posicao_destino: posicaoFinal,
                movimentos_com_remocao_a_realizar: movimentosARealizar
            },
            function (resource) {
                console.log(resource);
                movimentosARealizar = resource.movimento.movimentos_com_remocao_a_realizar;
                var casaInicial = document.getElementById(letras[posicaoInicial.x] + (posicaoInicial.y + 1));
                var casaDestino = document.getElementById(letras[posicaoFinal.x] + (posicaoFinal.y + 1));
                if (!resource.resposta) { // movimento nao valido
                    var i;
                    casaInicial.style.border = "";
                    if (resource.erros.constructor == Array) {
                        for (i in resource.erros) {
                            erros = erros + "\n " + resource.erros[i];
                        }
                        alert(erros);
                        erros = '';
                    } else {
                        alert(resource.erros);
                    }
                } else { // movimento valido
                    casaDestino.setAttribute('peça', casaInicial.getAttribute('peça'));
                    if (resource.movimento.eh_com_remocao) { // movimento tem remoção
                        var casaPecaRemovida = document.getElementById(letras[resource.movimento.posicao_da_peca_no_caminho.x]
                            + (resource.movimento.posicao_da_peca_no_caminho.y + 1));
                        casaPecaRemovida.setAttribute('peça', '0');
                        casaPecaRemovida.removeAttribute('style');
                    }
                    if (resource.movimento.peca_vira_dama) { // peça vira dama
                        if (resource.movimento.peca_a_movimentar.cor == "PRETA") {
                            casaDestino.style.backgroundImage = "url('dama-verde.jpg')";
                        } else {
                            casaDestino.style.backgroundImage = "url('dama-azul.jpg')";
                        }
                    } else {
                        casaDestino.style.backgroundImage = casaInicial.style.backgroundImage;
                    }
                    casaInicial.setAttribute('peça', '0');
                    casaInicial.removeAttribute('style');
                    return $q.defer(resource.vez.jogador.cor_das_pecas);
                }
            }, function (response) {//deu erro na validação (não que o movimento seja invalido)
                console.log(response);
            })
    }

    self.move = function (casa, valor, tabuleiro) {
        var jogador1=tabuleiro.jogadores[0];
        var jogador2=tabuleiro.jogadores[1];
        if (valorCasa == 5) { // primeiro Click
            if (valor != 0) {
                if (vez == valor) {
                    var x = letras.indexOf(casa.id.charAt(0));
                    var y = casa.id.charAt(1) - 1;
                    casa.style.border = "3px solid yellow";
                    posicaoInicial.x = x;
                    posicaoInicial.y = y;
                    valorCasa = valor;
                }
            }
        } else { // segundo click
            var x = letras.indexOf(casa.id.charAt(0));
            var y = casa.id.charAt(1) - 1;
            posicaoFinal.x = x;
            posicaoFinal.y = y;
            identificador = tabuleiro.identificador;
            console.log(valor);
            console.log(valorCasa);
            if (valorCasa == valor) {//clico numa peça da mesma cor
                var casaInicial = document.getElementById(letras[posicaoInicial.x] + (posicaoInicial.y + 1));
                casaInicial.style.border = "";
                casaInicial = document.getElementById(letras[posicaoFinal.x] + (posicaoFinal.y + 1));
                posicaoInicial.x = x;
                posicaoInicial.y = y;
                casaInicial.style.border = "3px solid yellow";
                valorCasa = valor;
            } else {

                //valida movimento
                if (movimentosARealizar != null) {
                    vez = self.validaMovimento(identificador, posicaoInicial, posicaoFinal);
                    vez.$promise.then(function (response) {
                        vez = response.vez.jogador.cor_das_pecas;
                        acabou = response.acabou.quem_ganhou;
                        return self.verificaSeAcabou(acabou,jogador1,jogador2);
                    })
                } else {
                    vez = self.validaMovimento(identificador, posicaoInicial, posicaoFinal, null);
                    vez.$promise.then(function (response) {
                        vez = response.vez.jogador.cor_das_pecas;
                        acabou = response.acabou.quem_ganhou;
                        return self.verificaSeAcabou(acabou,jogador1,jogador2);
                    })
                }

                valorCasa = 5;
            }
        }
    }
    self.verificaSeAcabou = function(acabou,jogador1,jogador2){
        if(acabou!=null){
            valorCasa = 5;
            vez = "BRANCA";
            erros = "";
            movimentosARealizar = null;
            var a;
            if(jogador1.tipo=="HUMANO" && jogador2.tipo=="HUMANO"){
                if(acabou.cor_das_pecas=="BRANCA"){
                    //jogador 1 venceu
                    alert("jogador1 venceu");
                }else{
                    //jogador 2 venceu
                    alert("jogador2 venceu");
                }                
            }else{
                if(jogador1.tipo=="HUMANO" || jogador2.tipo=="HUMANO"){
                    //verifica pelo tipo e voce perdeu/voce ganhou
                    if(acabou.tipo=="HUMANO"){
                        //VOCE VENCEU
                        alert("venceu");
                    }else{
                        //VOCE PERDEU
                        alert("perdeu");
                    }
                }else{
                    if(acabou.cor_das_pecas=="BRANCA"){
                    //IA 1 venceu
                    }else{
                    //IA 2 venceu
                    } 
                }
            }
        }
    }
    return self;
}