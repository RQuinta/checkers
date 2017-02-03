var app = angular.module('Damas', ['ui.router', 'ngResource','ui.bootstrap','angular-loading-bar']);
app.config(function ($stateProvider, $urlRouterProvider, $locationProvider,cfpLoadingBarProvider) {
    cfpLoadingBarProvider.latencyThreshold = 500;
    $locationProvider.html5Mode({
        enabled: true,
        requireBase: true
    });
    $urlRouterProvider.otherwise('/');

    $stateProvider
        .state('main', {
            url: '/',
            templateUrl: './assets/main.html',
            controller: 'mainctrl'
        })
        .state('root', {
            url: '/main',
            templateUrl: './assets/root.html'
        })
        .state('pvai', {
            url: '/playervsai',
            templateUrl: './assets/playervsai.html',
            controller: 'pviactrl'
        })
        .state('pvp', {
            url: '/playervsplayer',
            templateUrl: './assets/playervsplayer.html',
            controller: 'pvpctrl'
        })
        .state('iavsia', {
            url: '/iavsia',
            templateUrl: './assets/iavsia.html',
            controller: 'iavsia'
        })
        .state('instrucoes', {
            url: '/instrucoes',
            templateUrl: './assets/instrucoes.html'
        })
});


app.factory('Partida', ['$resource', Partida]);
app.factory('Movimento', ['$resource', Movimento]);
app.factory('ValidacaoMovimento', ['Movimento', 'Partida', '$q', validacaoMovimento]);
app.factory('Tabuleiro', ['ValidacaoMovimento', 'Partida','$q', Tabuleiro]);
app.controller('pviactrl', ['$scope', 'Tabuleiro','Movimento','$q','$modal','$timeout', Pvaictrl]);
app.controller('pvpctrl', ['$scope', 'Tabuleiro','Movimento','$q','$modal', Pvpctrl]);
app.controller('iavsia', ['$scope', 'Tabuleiro','Movimento','$q','$modal','$timeout', Iavsiactrl]);
app.controller('mainctrl', ['$scope', mainctrl]);
