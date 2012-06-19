EM.endpoint({
    name: 'global check'
  , route: '/globals'
  , methods: 'GET'
  , handler: function () {
        this.respond(200, 'text', LOG +' and '+ DB);
        return;
    }
})

