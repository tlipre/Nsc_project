$ ->
  editor = $('#editor')
  terminal = $('#terminal')
  docker = $('.docker')
  editor.focus()
  socket = io('/terminal');

  socket.on 'connect', ()->
    socket.emit 'request_terminal', terminal.data("container-id")
    socket.emit 'data', terminal.data("container-id"), "\n"
  term = new Terminal {
    cols: 60,
    rows: 15,
    useStyle: true,
    screenKeys: true,
    cursorBlink: true
  }
  term.on 'data', (data)->
    socket.emit 'data', terminal.data("container-id"), data
  term.open($('#terminal').get(0))
  socket.on 'data', (data)->
    term.write data
  socket.on 'disconnect', ()->
    term.destroy()
    
  docker.click ()->
    terminal.data("container-id", $(this).data('id'))
    socket.emit 'request_terminal', terminal.data("container-id")
    term.reset()
    socket.emit 'data', terminal.data("container-id"), "\n"

  $('#save').click ()->
  #TODO: handler error(s)
    file_name = prompt 'Enter file name.', 'untitled'
    while file_name == ''
      file_name = prompt 'Enter file name again.', 'untitled'
    $.post  "/e-classroom/editor", { code: editor.val(), file_name: file_name, container_id: terminal.data("container-id")}

    
