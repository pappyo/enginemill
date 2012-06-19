PATH = require 'path'
EventEmitter = require('events').EventEmitter


describe 'server', ->
    PROC = require 'proctools'
    gPID = null

    startServerProcess = (aOpts, aCallback) ->
        onfailure = (err) ->
            if /listen\sEADDRINUSE/.test(err.stack or err.toString())
                msg = "Conflicting server address in use. "
                msg += "Try killing old processes."
                return aCallback(new Error(msg))
            return aCallback(err)

        cmd =
            command: PATH.resolve(__dirname, '../dist/enginemill.js')
            buffer: yes
            args: [
                '--address', 'localhost'
                '--port', 8080
                '--dir', PATH.join(__dirname, 'fixtures', 'default-app')
            ]
        PROC.runCommand(cmd).fail(onfailure).then (proc) ->
            gPID = proc.pid
            rv = {proc: proc, emitter: new EventEmitter()}

            proc.stdout.setEncoding('utf8')
            proc.stdout.on 'data', (chunk) ->
                rv.emitter.emit('stdout', chunk)
                return

            proc.stderr.setEncoding('utf8')
            proc.stderr.on 'data', (chunk) ->
                rv.emitter.emit('stderr', chunk)
                return

            return aCallback(null, rv)
        return

    afterEach (done) ->
        if gPID is null then return done()
        PROC.kill(gPID).fail(done).then ->
            return done()
        return


    it 'should', (done) ->
        @expectCount(2)
        startServerProcess null, (err, rv) ->
            if err then return done(err)
            {proc, emitter} = rv
            line = JSON.parse(proc.stdoutBuffer.split('\n')[0])
            expect(line.level).toBe(30)
            expect(line.msg).toBe('Engine Mill Webapp running on 127.0.0.1:8080')
            return done()
        return

    return
