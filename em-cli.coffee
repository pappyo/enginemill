FS = require 'fs'
PATH = require 'path'

OPT = require 'optimist'
PROC = require 'proctools'
DNODE = require 'dnode'

APPS = require './lib/apprunner'

main = (args) ->
    cmd = args[0]

    switch cmd
        when 'run' then do_run()
        when 'deploy' then do_deploy()
        else
            console.log "Unknown command `#{cmd}`"
            console.log "Use `run` or `deploy`"
            process.exit(1)
    return

do_deploy = ->
    opts = OPT.usage("Deploy your Engine Mill app to the Engine Mill servers")
        .options({'remote': {alias: 'r', 'default': 'webserver.fwp-dyn.com'}})
        .describe('remote', "Hostname of the remote server")
        .options({'dir': {alias: 'd'}})
        .describe('dir', "Path to the local application directory")
        .argv

    # Defaults to process.cwd()
    source = PATH.resolve(process.cwd(), opts.dir).replace(/\/$/, '')
    app_ini = PATH.join(source, 'app.ini')
    
    try
        appconf = FS.readFileSync(app_ini, 'utf8')
    catch readError
        console.error """It does not appear that `#{source}` is an Engine Mill application directory:
        Missing `app.ini` file in `#{source}/`
        """
        process.exit()

    appconf = appconf.split('\n')
    appname = appconf[0].trim()
    apphost = appconf[1].trim()
    bindir = PATH.join(__dirname, 'bin')
    deploy_sh = PATH.join(bindir, 'deploy.sh')
    keyfile = PATH.join(process.env['HOME'], '.ssh', 'webserver-key-1.pem')

    cmd =
        command: deploy_sh
        args: [
            keyfile
            opts.remote
            source
            appname
        ]
        timeLimit: 10000

    onfailure = (err) ->
        console.error """There was an error while attempting to deploy the Engine Mill application at:
        `#{source}`:\n
        """
        console.error "failed executing #{deploy_sh}:"
        console.error(err.stack or err.toString())
        process.exit(err.code)

    PROC.runCommand(cmd).fail(onfailure).then (proc) ->
        process.stdout.write(proc.stdoutBuffer)
        restart_app appname, apphost, opts.remote, (err, res) ->
            process.stdout.write('\n')
            if err
                console.error """There was a problem while attempting to restart your remote Engine Mill application:\n
                    """
                console.error(err.stack)
                return
            console.log("#{appname} deployed")
            return
        return

    return


do_run = ->
    opts = OPT.usage("Run the Engine Mill development server")
        .options({'address': {alias: 'a', 'default': 'localhost'}})
        .describe('address', "Hostname or IP address to run on")
        .options({'port': {alias: 'p', 'default': 8080}})
        .describe('port', "The port run on")
        .options({'dir': {alias: 'd'}})
        .describe('dir', "Path to the local application directory")
        .argv

    # Defaults to process.cwd()
    source = PATH.resolve(process.cwd(), opts.dir)

    appOpts =
        path: source
        hostname: opts.address
        port: opts.port
    server = APPS.main appOpts, (err, addr) ->
        if err
            console.error "There was a problem starting the development server:"
            console.error(err.stack or err.toString())
            process.exit(2)

        console.log "dev server running on #{addr.address}:#{addr.port}"
        return
    return


restart_app = (aApp, aHost, aRemote, aCallback) ->
    cxn = DNODE.connect 7272, aRemote, (remote) ->
        remote.register_app {name: aApp, hostname: aHost}, (err, res) ->
            if err
                msg = "remote register_app error: #{err.message}"
                return aCallback(new Error(msg))

            remote.restart_app aApp, (err, res) ->
                cxn.end()
                if err
                    msg = "remote restart_app error: #{err.message}"
                    return aCallback(new Error(msg))
                return aCallback()
            return
        return

    cxn.once 'error', (err) ->
        msg = "unexpected Dnode connection error: #{err.message}"
        aCallback(new Error(msg))
        return
    return

main(process.argv.slice(2))
