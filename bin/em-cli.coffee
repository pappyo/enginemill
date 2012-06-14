FS = require 'fs'
PATH = require 'path'

OPT = require 'optimist'
PROC = require 'proctools'

main = (args) ->
    cmd = args[0]

    switch cmd
        when 'run' then console.log 'RUNLOCALAPP'
        when 'deploy' then do_deploy()
        else
            console.log "Unknown command `#{cmd}`"
            console.log "Use `run` or `deploy`"
            process.exit 1
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
        appname = FS.readFileSync(app_ini, 'utf8')
    catch readError
        console.error """It does not appear that `#{source}` is an Engine Mill application directory:
        Missing `app.ini` file in `#{source}/`
        """
        process.exit()

    appname = appname.trim()
    bindir = __dirname
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
        console.log("#{appname} deployed")
        return
    return

main(process.argv.slice(2))
