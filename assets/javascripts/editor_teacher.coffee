$ ->
  socket = io('/editor')
  docker = $('.docker')
  status_changer = $('#status-changer')
  editor = ace.edit("editor-teacher")
  quiz_creator = $('#quiz-creator')

  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false
  editor.$blockScrolling = Infinity

  current_view = $("#current-view")
  current_profile_picture = $("#current-profile-picture")

  quiz_creator.click ()->
    quiz_name = $('#quiz-name').val()
    room_name = get_room_name()
    choice1 = $('#choice1').val()
    choice2 = $('#choice2').val() 
    choice3 = $('#choice3').val()
    choice4 = $('#choice4').val()
    $.post "../quiz",
      room_name: room_name, 
      quiz_name: quiz_name, 
      item_count: 1,
      items: { 1: [choice1, choice2, choice3, choice4]}, 
      (data)->
        alert data

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

  editor.on "change", (e)->
    if (editor.curOp && editor.curOp.command.name) 
      socket.emit 'type_teacher', editor.getValue()

  socket.on 'type_student', (data)->
    editor.setValue(data)

  socket.on 'init', (data)->
    editor.setValue data

get_room_name = ()->
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher
  current_url = window.location.href
  
  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')
  
  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)
  return room_name
  

