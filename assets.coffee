module.exports = (assets) ->
  assets.root = __dirname
  assets.addJs '/public/javascripts/jquery-1.11.3.js'
  
  assets.addJs '/assets/javascripts/terminal.coffee', 'terminal'
  assets.addJs '/public/javascripts/socket.io-1.2.0.js', 'socket'
  assets.addJs '/assets/javascripts/chat.coffee', 'chat'
  assets.addJs '/assets/javascripts/editor.coffee', 'editor'
  assets.addJs '/assets/javascripts/editor_teacher.coffee', 'editor_teacher'
  assets.addCss '/public/stylesheets/bootstrap/css/bootstrap.css'
  assets.addCss '/assets/stylesheets/style.styl'
  

