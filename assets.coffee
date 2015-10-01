module.exports = (assets) ->
  assets.root = __dirname
  assets.addJs '/public/javascripts/jquery-1.11.3.js'
  assets.addJs '/public/javascripts/socket.io-1.2.0.js', 'socket'

  assets.addJs '/assets/javascripts/state.coffee'
  assets.addCss '/assets/stylesheets/test.styl'
  assets.addJs '/assets/javascripts/terminal.coffee', 'terminal'
  