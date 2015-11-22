$ ->
  socket = io('/editor')
  editor = $('.editor')

  socket.on 'connect', ()->
    socket.emit 'request_container'

  editor.keyup ()->
    socket.emit 'type_student', editor.val()

  socket.on 'type_teacher', (data)->
    editor.val data
    
  socket.on 'init', (data)->
    editor.val data
