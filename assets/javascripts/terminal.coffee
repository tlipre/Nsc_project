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

  window.file_name = null
  is_first = true
  $('#save-as').click ()->
  #TODO: handler error(s)
    window.file_name = prompt 'Enter file name.', 'untitled'
    while window.file_name == ''
      window.file_name = prompt 'Enter file name again.', 'untitled'
    $.post "/e-classroom/editor", { code: editor.val(), file_name: window.file_name, container_id: terminal.data("container-id")}
    term.write "File: #{file_name} saved."
    socket.emit 'data', terminal.data("container-id"), "\n"
    if is_first
      $('#save').removeAttr("disabled")
      is_first = false

  $('#save').click ()->
    $.post "/e-classroom/editor", { code: editor.val(), file_name: window.file_name, container_id: terminal.data("container-id")}
    term.write "File: #{file_name} saved."
    socket.emit 'data', terminal.data("container-id"), "\n"
