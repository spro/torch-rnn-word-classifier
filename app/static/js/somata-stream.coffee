Kefir = require 'kefir'
somata = require './somata-socketio'

remote = (service, method, args...) ->
    Kefir.stream (emitter) ->
        console.log "[somata_stream.remote] #{service}.#{method}(#{args})"
        somata.remote service, method, args..., (err, result) ->
            if err
                emitter.error(err)
            else
                emitter.emit(result)
            emitter.end()

subscribe = (service, method, args...) ->
    Kefir.stream (emitter) ->
        console.log "[somata_stream.subscribe] #{service}.#{method}(#{args})"
        somata.subscribe service, method, args..., (result) ->
            console.log "[somata_stream.subscribe] #{service}.#{method}(#{args})", result
            emitter.emit(result)

extend = (o1, o2) ->
    o = {}
    for k1, v1 of o1
        o[k1] = v1
    for k2, v2 of o2
        o[k2] = v2
    o

module.exports = extend somata, {remote, subscribe}
