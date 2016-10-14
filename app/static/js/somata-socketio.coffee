# Connect to the Socket.io server

socket = io.connect()
exports.socket = socket

# Call a remote service's method

exports.remote = (service, method, args..., cb) ->
    socket.emit 'remote', service, method, args..., cb

# Subscribe to a service's events

subscriptions = {}
exports.subscribe = (service, type, cb) ->
    subscriptions[service] ||= {}
    subscriptions[service][type] ||= []
    subscriptions[service][type].push cb
    socket.emit 'subscribe', service, type

# Handle published events

socket.on 'event', (service, type, event) ->
    if cbs = subscriptions[service][type]
        try
            cbs.map (cb) -> cb event
        catch e
            console.error "Died while handling response...", e.stack

# Resubscribe when reconnecting

connected = false
authenticated = false
first_connect = true

didConnect = ->
    connected = true
    console.log '[didConnect] Connected...'
    socket.emit 'hello', token

didAuthenticate = (cb) -> (user) ->
    console.log '[didAuthenticate] Authenticated as', user
    # Prevent re-connecting on initial load
    if first_connect
        first_connect = false
        cb(null, user)
    else
        reSubscribe()

reSubscribe = ->
    # Re-connect known subscriptions
    for service, types of subscriptions
        for type, fns of types
            socket.emit 'subscribe', service, type

exports.authenticate = (cb) ->
    socket.on 'hello', didConnect
    socket.on 'welcome', didAuthenticate cb

