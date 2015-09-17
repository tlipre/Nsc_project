module.exports = (app) ->
  io = require('socket.io').listen(server)
  state = []
  app.get '/provider', (req, res) ->
    res.render 'provider'

  app.get '/receiver', (req, res) ->
    res.render 'receiver'

  app.get '/state', (req, res) ->
    console.log state
    res.render 'state', {data: state}

  app.get '/img', (req, res) ->
    res.sendfile "public/Test_animation.gif"

  io.on 'connection', (socket) ->
    socket.on 'editor', (message) ->
      state.push message
      io.emit 'broadcast', message