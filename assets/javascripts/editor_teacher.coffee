$ ->
  socket = io('/editor')
  docker = $('.docker')
  editor = $('.editor')
  current_view = $("#current-view")
  current_profile_picture = $("#current-profile-picture")

  socket.on 'connect', ()->
    socket.emit 'request_container'

  docker.click ()->
    #MTODO: loading animation
    container_id = $(this).data('id')
    container_owner = $(this).data('owner')
    socket.emit 'request_container_teacher', container_id    
    current_view.text container_owner
    current_profile_picture.attr 'src', "/uploads/profile_picture/#{container_owner}.jpg"

  editor.keyup ()->
    socket.emit 'type_teacher', editor.val()
  
  socket.on 'type_student', (data)->
    editor.val(data)

  socket.on 'init', (data)->
    editor.val data

