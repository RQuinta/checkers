function Iavsiactrl($scope, Tabuleiro, Movimento, $q, $modal,$timeout) {
    $scope.letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    $scope.vez = "BRANCA";
    Tabuleiro.montaTabela();
    var partida = Tabuleiro.criaPartida("IA", "IA");
    partida.$promise.then(function (response) {
        $scope.jogador1 = response.jogadores[0];
        $scope.jogador2 = response.jogadores[1];
        console.log(partida.identificador);

    $scope.moveIA();
    })
    $scope.posicaoInicial = {
        x: null,
        y: null
    };
    $scope.posicaoFinal = {
        x: null,
        y: null
    };
    $scope.acabou = null;
    $scope.moveIA = function(){
            Movimento.create({
                    partida_identificador: partida.identificador,
                    tipo_jogador: "IA"
                }, function (response) {
                    for (var i = 0; i < response.movimentos.length; i++) {
                        console.log(response.movimentos[i]);
                        var casaInicial = document.getElementById($scope.letras[response.movimentos[i].posicao_inicial.x] + (response.movimentos[i].posicao_inicial.y + 1));
                        casaInicial.style.border = "3px solid yellow";
                        console.log(casaInicial.style.border);
                        console.log(casaInicial);
                        var casaDestino = document.getElementById($scope.letras[response.movimentos[i].posicao_destino.x] + (response.movimentos[i].posicao_destino.y + 1));
                        console.log(casaDestino);
                        casaDestino.style.backgroundImage = casaInicial.style.backgroundImage;
                        casaDestino.setAttribute('peça', casaInicial.getAttribute('peça'));
                        casaInicial.removeAttribute('style');
                        casaInicial.setAttribute('peça', 0);
                        if (response.movimentos[i].peca_vira_dama) { // peça vira dama
                        if (response.movimentos[i].peca_a_movimentar.cor == "PRETA") {
                            casaDestino.style.backgroundImage = "url('dama-verde.jpg')";
                        } else {
                            casaDestino.style.backgroundImage = "url('dama-azul.jpg')";
                        }
                    }
                        if (response.movimentos[i].eh_com_remocao) {
                            var casaPecaRemovida = document.getElementById($scope.letras[response.movimentos[i].posicao_da_peca_no_caminho.x]
                            + (response.movimentos[i].posicao_da_peca_no_caminho.y + 1));
                            casaPecaRemovida.setAttribute('peça', '0');
                            casaPecaRemovida.removeAttribute('style');
                        }
                    }
                    $scope.acabou = response.acabou;
                    $scope.verificaSeAcabou();
                }
            )
    }
    $scope.verificaSeAcabou = function () {
        if ($scope.acabou.resposta) {
            if ($scope.acabou.quem_ganhou == null) {
                $scope.msgVencedor = "Empatou!";
                $scope.open('sm');
            } else {
                if ($scope.acabou.quem_ganhou == "PRETA") {
                    //jogardor da peça
                    $scope.msgVencedor = "IA das peças verde ganhou!";
                    $scope.open('sm');
                } else {
                    //jogador 2 ganhou
                    $scope.msgVencedor = "IA das peças azuis ganhou!";
                    $scope.open('sm');
                }
            }
        }else{
            $scope.moveIA();
        }
    }
    $scope.open = function (size) {
        $scope.modalInstance = $modal.open({
            animation: true,
            templateUrl: '/assets/modal.html',
            backdrop: 'static',
            scope: $scope,
            windowClass: 'center-modal',
            size: size
        });
    }
    $scope.cancel = function () {
        $scope.modalInstance.dismiss('cancel');
    };
}