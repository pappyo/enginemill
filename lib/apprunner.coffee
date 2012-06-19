FS = require 'fs'
PATH = require 'path'
VM = require 'vm'

COFFEE = require 'coffee-script'


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

    context =
        EM: APP

    if typeof aOpts.appGlobals
        for own p, v of aOpts.appGlobals
            context[p] = v
    loadAppfile(path, context)

    server = APP.run port, hostname, (addr) ->
        APP.on 'error', (err) ->
            return server.emit('error', err)
        return resolve(null, addr)

    return server

loadAppfile = (aPath, aContext) ->
    {text, appfile} = readAppfile(aPath)
    if not text then return
    context = VM.createContext(aContext)
    VM.runInContext(text, context, appfile)
    return

readAppfile = (aRoot) ->
    extensions = ['js', 'coffee']

    for ext in extensions
        appfile = PATH.join(aRoot, "app.#{ext}")
        try
            text = FS.readFileSync(appfile, 'utf8')
            if ext is 'coffee'
                text = COFFEE.compile(text)
            return {text: text, appfile: appfile}
        catch readError
            if readError.code is 'ENOENT' then continue
    return {text: null, appfile: null}
