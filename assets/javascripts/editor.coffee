$ ->
  editor = $('.editor')
  student = $('.docker')

  socket = io('/editor');
  editor.keyup ()->
    socket.emit 'message', editor.val()
  socket.on 'request1', (data)->
    socket.emit 'message', editor.val()

