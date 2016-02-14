$ ->
  socket = io('/editor')

  editor = ace.edit("editor");
  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false
  classroom_name = get_room_name()

  socket.on 'connect', ()->
    socket.emit 'request_container'

  editor.on "change", (e)->
    if (editor.curOp && editor.curOp.command.name)
      #if change by user not programmatically
      socket.emit 'type_student', editor.getValue()

  socket.on 'type_teacher', (data)->
    editor.setValue data
    
  socket.on 'init', (data)->
    editor.setValue data

  $.get "../quiz?classroom_name="+classroom_name,
    (data)->
      console.log data



get_room_name = ()->
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher
  current_url = window.location.href
  
  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')
  
  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)
  return room_name
  