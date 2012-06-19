PATH = require 'path'
MOD = require 'module'


exports.main = (aOpts, aCallback) ->
    server = null
    path = aOpts.path
    port = aOpts.port
    hostname = aOpts.hostname
    emitter = aOpts.emitter

    resolved = no
    resolve = (err, info) ->
        if resolved then return
        resolved = yes
        return aCallback(err, info)

    JAXN = require 'jaxn'
    APP = JAXN.app({root: path})
    APP.context({cdn: '/'})

    APP.once('error', resolve)

    global.EM = APP
    if typeof aOpts.appGlobals
        for own p, v of aOpts.appGlobals
            global[p] = v

    appfile = PATH.join(path, 'app')
    require('coffee-script')
    if MOD._findPath(appfile) then require(appfile)

    server = APP.run port, hostname, (addr) ->
        APP.removeListener('error', resolve)
        if emitter
            emit = (event, args) ->
                args.unshift(event)
                return emitter.emit.apply(emitter, args)

            APP.on 'error', (args...) ->
                return emit('error', args)
            APP.on 'warning', (args...) ->
                return emit('warning', args)
            APP.on 'info', (args...) ->
                return emit('info', args)

        return resolve(null, addr)

    return server
