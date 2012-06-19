EM.endpoint({
    name: 'coffeescript'
    route: '/'
    methods: 'GET'
    handler: ->
        @respond(200, 'text', 'mmmmm; coffee')
        return
})
