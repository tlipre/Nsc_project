$ ->
  socket = io('/editor')
  editor = $('.editor')

  socket.on 'connect', ()->
    socket.emit 'request_container'

  editor.keyup ()->
    socket.emit 'type', editor.val()

  socket.on 'type', (data)->
    editor.val(data)
