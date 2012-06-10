OPT = require 'optimist'

main = (args) ->
    cmd = args[0]
    console.log('CMD', cmd)
    return

main(process.argv.slice(2))
