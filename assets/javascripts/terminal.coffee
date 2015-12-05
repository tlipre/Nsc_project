$ ->
  editor = $('#editor')
  editor.focus()
  socket = io('/terminal');
  container_id = $("#terminal").data("container-id")
  socket.on 'connect', ()->
    socket.emit 'request_terminal', container_id
    socket.emit 'data', container_id, "\n"
  term = new Terminal {
    cols: 80,
    rows: 24,
    useStyle: true,
    screenKeys: true,
    cursorBlink: true
  }

  term.on 'data', (data)->
    socket.emit 'data', container_id, data
  term.open($('#terminal').get(0))
  socket.on 'data', (data)->
    term.write data
  socket.on 'disconnect', ()->
    term.destroy()
    

  $('#save').click ()->
  #TODO: handler error(s)
    file_name = prompt 'Enter file name.', 'untitled'
    while file_name == ''
      file_name = prompt 'Enter file name again.', 'untitled'
    $.post  "/e-classroom/student", { code: editor.val(), file_name: file_name}

    
