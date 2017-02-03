function Movimento($resource) {
    return $resource("api/movimentos/:id.json", {id: '@id'}, {
        create: {method: 'POST'},
        update: {method: 'PUT'},
        index: {method: 'GET'},
        show: {method: 'SHOW'}
    });
}
