PATH = require 'path'

OPT = require 'optimist'
BUN = require 'bunyan'

APPS = require '../lib/apprunner'


exports.main = ->
    opts = OPT.usage("Run the Engine Mill development server")
        .options({'address': {alias: 'a', 'default': 'localhost'}})
        .describe('address', "Hostname or IP address to run on")
        .options({'port': {alias: 'p', 'default': 8080}})
        .describe('port', "The port run on")
        .options({'dir': {alias: 'd'}})
        .describe('dir', "Path to the local application directory")
        .options({'name': {alias: 'n', 'default': 'Engine Mill Webapp'}})
        .describe('name', "The given name of the application.")
        .argv

    log = BUN.createLogger({name: opts.name})

    # Defaults to process.cwd()
    source = PATH.resolve(process.cwd(), opts.dir)

    appOpts =
        path: source
        hostname: opts.address
        port: opts.port
    server = APPS.main appOpts, (err, addr) ->
        if err
            console.error "There was a problem starting the Engine Mill server:"
            console.error(err.stack or err.toString())
            process.exit(2)

        log.info "#{opts.name} running on #{addr.address}:#{addr.port}"
        return
    return
