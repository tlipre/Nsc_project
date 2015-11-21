$ ->
  socket = io('/editor')
  docker = $('.docker')
  editor = $('.editor')
  current_view = $("#current_view")

  socket.on 'connect', ()->
    socket.emit 'request_container'

  docker.click ()->
    container_id = $(this).data('id')
    container_owner = $(this).data('owner')
    socket.emit 'request_container_teacher', container_id    
    current_view.text container_owner

  socket.on 'type', (data)->
    editor.val(data)

  editor.keyup ()->
    socket.emit 'type_teacher', editor.val()
  


