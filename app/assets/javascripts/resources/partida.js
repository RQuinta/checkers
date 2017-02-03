function Partida($resource) {
    return $resource("api/partidas/:id.json", {id: '@id'}, {
        create: {method: 'POST'},
        update: {method: 'PUT'},
        show: {method: 'SHOW'}
    });
}