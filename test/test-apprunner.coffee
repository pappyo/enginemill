PATH = require 'path'

REQ = require 'request'

FIXTURES = PATH.join(__dirname, 'fixtures')
DEFAULT_APP = PATH.join(FIXTURES, 'default-app')

describe 'apprunner', ->
    APR = require '../dist/lib/apprunner'

    gServer = null

    createApp = (opts, callback) ->
        defaults =
            path: DEFAULT_APP
            hostname: 'localhost'
            port: 8001

        if opts
            for own p, v of opts
                defaults[p] = v

        gServer = APR.main(defaults, callback)
        return gServer

    afterEach (done) ->
        if gServer is null then return done()
        onclose = ->
            gServer = null
            return done()
        gServer.once('close', onclose)
        gServer.close()
        return

    it 'should start on given host and port', (done) ->
        @expectCount(2)
        createApp null, (err, info) ->
            if err then return done(err)
            expect(info.address).toBe('127.0.0.1')
            expect(info.port).toBe(8001)
            return done()
        return

    it 'should accept an HTTP request', (done) ->
        @expectCount(2)
        createApp null, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.statusCode).toBe(200)
                expect(res.headers['content-type']).toBe("text/html; charset=utf-8")
                return done()
            return
        return


    it 'should set default template context', (done) ->
        @expectCount(2)
        createApp null, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001/default_context.txt'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.statusCode).toBe(200)
                expect(res.body).toBe('cdn=/')
                return done()
            return
        return


    it 'should run an application file', (done) ->
        @expectCount(1)
        appGlobals =
            LOG: 'log-util'
            DB: 'database'

        createApp {appGlobals: appGlobals}, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001/globals'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.statusCode).toBe(200)
                return done()
            return
        return


    it 'should allow no application file', (done) ->
        @expectCount(1)
        createApp {path: PATH.join(FIXTURES, 'no-appfile')}, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001/'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.statusCode).toBe(200)
                return done()
            return
        return


    it 'should handle application file error', (done) ->
        @expectCount(1)
        try
            createApp({path: PATH.join(FIXTURES, 'appfile-error')})
        catch err
            expect(err.message).toBe('appfile test error')
        return done()


    it 'should allow CoffeeScript application file', (done) ->
        @expectCount(1)
        createApp {path: PATH.join(FIXTURES, 'coffeescript-appfile')}, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001/'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.statusCode).toBe(200)
                return done()
            return
        return


    it 'should set globals', (done) ->
        @expectCount(1)
        appGlobals =
            LOG: 'log-util'
            DB: 'database'

        createApp {appGlobals: appGlobals}, (err, info) ->
            if err then return done(err)
            return test()

        test = ->
            opts =
                uri: 'http://localhost:8001/globals'
            REQ.get opts, (err, res, body) ->
                if err then return done(err)
                expect(res.body).toBe('log-util and database')
                return done()
            return
        return

    return
