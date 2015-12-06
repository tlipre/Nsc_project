$ ->
  socket = io('/editor')
  docker = $('.docker')
  editor = $('.editor')
  status_changer = $('#status-changer')

  current_view = $("#current-view")
  current_profile_picture = $("#current-profile-picture")

  socket.on 'connect', ()->
    socket.emit 'request_container'

  status_changer.click ()->
    if status_changer.hasClass('red')
      status_changer.removeClass('red')
      status_changer.val("Allowed")
    else
      status_changer.addClass('red')
      status_changer.val("Disallowed")
    socket.emit 'toggle'

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

