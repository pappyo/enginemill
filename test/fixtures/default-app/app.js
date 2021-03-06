EM.endpoint({
    name: 'appfile'
  , route: '/app'
  , methods: 'GET'
  , handler: function () {
        tool = require('./lib/tool');
        this.respond(200, 'text', tool.foo);
        return;
    }
});

EM.endpoint({
    name: 'global check'
  , route: '/globals'
  , methods: 'GET'
  , handler: function () {
        this.respond(200, 'text', LOG +' and '+ DB);
        return;
    }
});

EM.endpoint({
    name: 'throw error'
  , route: '/throw-error'
  , methods: 'GET'
  , handler: function () {
      throw new Error('bad error');
    }
});
