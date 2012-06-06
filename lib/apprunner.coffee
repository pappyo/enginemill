EventEmitter = require('events').EventEmitter

exports.main = (aOpts, aCallback) ->
    server = null
    path = aOpts.path
    port = aOpts.port
    hostname = aOpts.hostname

    resolved = no
    resolve = (err, info) ->
        if resolved then return
        resolved = yes
        return aCallback(err, info)

    JAXN = require 'jaxn'
    APP = JAXN.app({root: path})
    APP.context({cdn: '/'})

    APP.once('error', resolve)

    server = APP.run port, hostname, (addr) ->
        APP.on 'error', (err) ->
            return server.emit('error', err)
        return resolve(null, addr)

    return server
