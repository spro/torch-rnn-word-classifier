polar = require 'somata-socketio'

app = polar port: 3566

app.get '/', (req, res) ->
    res.render 'index'

app.start()
