PATH = require 'path'

REQ = require 'request'

FIXTURES = PATH.join(__dirname, 'fixtures')
DEFAULT_APP = PATH.join(FIXTURES, 'default-app')

describe 'apprunner', ->
    APR = require '../dist/lib/apprunner'

    gServer = null

    createApp = (opts, callback) ->
        opts =
            path: DEFAULT_APP
            hostname: 'localhost'
            port: 8001

        gServer = APR.main(opts, callback)
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

    return
