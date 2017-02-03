function Pvpctrl($scope, Tabuleiro, Movimento, $q,$modal) {
    $scope.letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    $scope.vez = "BRANCA";
    $scope.corDaVez="Azul";
    Tabuleiro.montaTabela();
    var partida = Tabuleiro.criaPartida("HUMANO", "HUMANO");
    $scope.posicaoInicial = {
        x: null,
        y: null
    };
    $scope.posicaoFinal = {
        x: null,
        y: null
    };
    $scope.valorCasa = 5;
    $scope.erros = "";
    $scope.movimentosARealizar = null;
    $scope.criaOnClick = function () {
        for (var i = 1; i < 9; i++) { // as colunas
            for (var j = 0; j < 8; j++) { // as linhas
                var casa = document.getElementById($scope.letras[i - 1] + (j + 1));
                casa.onclick = function () {
                    $scope.move(this, this.getAttribute('peça'), partida);
                }
            }
        }
    }
    $scope.criaOnClick();
    $scope.move = function (casa, valor, tabuleiro) {
        var jogador1 = tabuleiro.jogadores[0];
        var jogador2 = tabuleiro.jogadores[1];
        if ($scope.valorCasa == 5) { // primeiro Click
            if (valor != 0) {
                if ($scope.vez == valor) {
                    var x = $scope.letras.indexOf(casa.id.charAt(0));
                    var y = casa.id.charAt(1) - 1;
                    casa.style.border = "3px solid yellow";
                    $scope.posicaoInicial.x = x;
                    $scope.posicaoInicial.y = y;
                    $scope.valorCasa = valor;
                }
            }
        } else { // segundo click
            var x = $scope.letras.indexOf(casa.id.charAt(0));
            var y = casa.id.charAt(1) - 1;
            $scope.posicaoFinal.x = x;
            $scope.posicaoFinal.y = y;
            identificador = tabuleiro.identificador;
            if ($scope.valorCasa == valor) {//clico numa peça da mesma cor
                var casaInicial = document.getElementById($scope.letras[$scope.posicaoInicial.x] + ($scope.posicaoInicial.y + 1));
                casaInicial.style.border = "";
                casaInicial = document.getElementById($scope.letras[$scope.posicaoFinal.x] + ($scope.posicaoFinal.y + 1));
                $scope.posicaoInicial.x = x;
                $scope.posicaoInicial.y = y;
                casaInicial.style.border = "3px solid yellow";
                $scope.valorCasa = valor;
            } else {

                //valida movimento
                if ($scope.movimentosARealizar != null) {
                    $scope.vez = $scope.validaMovimento(identificador, $scope.posicaoInicial, $scope.posicaoFinal);
                    $scope.vez.$promise.then(function (response) {
                        $scope.vez = response.vez.jogador.cor_das_pecas;
                        $scope.acabou = response.acabou;
                        
                        $scope.verificaSeAcabou();
                        if($scope.vez=="BRANCA"){
                $scope.corDaVez="Azul";
                }else{
                $scope.corDaVez="Verde"
                }   
                    })
                } else {
                    $scope.vez = $scope.validaMovimento(identificador, $scope.posicaoInicial, $scope.posicaoFinal, null);
                    $scope.vez.$promise.then(function (response) {
                        $scope.vez = response.vez.jogador.cor_das_pecas;
                        $scope.acabou = response.acabou;
                        $scope.verificaSeAcabou();
                        if($scope.vez=="BRANCA"){
                        $scope.corDaVez="Azul";
                        }else{
                        $scope.corDaVez="Verde"
                        }   
                    })

                }   
                $scope.valorCasa = 5;
            }
        }
    }
    $scope.validaMovimento = function (identificador, posicaoInicial, posicaoFinal, movimentosARealizar) {
        return Movimento.create({
                partida_identificador: identificador,
                posicao_inicial: posicaoInicial,
                posicao_destino: posicaoFinal,
                movimentos_com_remocao_a_realizar: movimentosARealizar,
                tipo_jogador: "HUMANO"
            },
            function (resource) {
                console.log(resource);
                $scope.movimentosARealizar = resource.movimento.movimentos_com_remocao_a_realizar;
                var casaInicial = document.getElementById($scope.letras[$scope.posicaoInicial.x] + ($scope.posicaoInicial.y + 1));
                var casaDestino = document.getElementById($scope.letras[$scope.posicaoFinal.x] + ($scope.posicaoFinal.y + 1));
                if (!resource.resposta) { // movimento nao valido
                    var i;
                    casaInicial.style.border = "";
                    if (resource.erros.constructor == Array) {
                        for (i in resource.erros) {
                            $scope.erros = $scope.erros + "\n " + resource.erros[i];
                        }
                        alert($scope.erros);
                        $scope.erros = '';
                    } else {
                        alert(resource.erros);
                    }
                } else { // movimento valido
                    casaDestino.setAttribute('peça', casaInicial.getAttribute('peça'));
                    if (resource.movimento.eh_com_remocao) { // movimento tem remoção
                        var casaPecaRemovida = document.getElementById($scope.letras[resource.movimento.posicao_da_peca_no_caminho.x]
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
    $scope.verificaSeAcabou = function () {
        if ($scope.acabou.resposta) {
            if($scope.acabou.quem_ganhou==null){
                $scope.msgVencedor="Empatou!";
                $scope.open('sm');
            }else{
                if ($scope.acabou.quem_ganhou == "BRANCA") {
                //jogardor 1 ganhou
                $scope.msgVencedor = "O jogador das peças azuis ganhou!";
                $scope.open('sm');
            } else {
                //jogador 2 ganhou
                $scope.msgVencedor = "O jogador das peças verdes ganhou!";
                $scope.open('sm');
            }    
            }
            
        }
    }

    $scope.open = function (size) {
        $scope.modalInstance = $modal.open({
            animation: true,
            templateUrl: '/assets/modal.html',
            backdrop:'static',
            scope:$scope,
            windowClass: 'center-modal',
            size: size
        });

    }
    $scope.cancel = function () {
        $scope.modalInstance.dismiss('cancel');
    };
   

    
}