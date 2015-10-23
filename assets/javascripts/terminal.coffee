$ ->
  editor = $('#editor')
  editor.focus()
  socket = io('/terminal');
  socket.on 'connect', ()-> 
    term = new Terminal {
      cols: 80,
      rows: 24,
      useStyle: true,
      screenKeys: true,
      cursorBlink: true
    }
    term.on 'data', (data)->
      socket.emit 'data', data
    term.on 'title', (title) ->
      document.title = title;
    term.open($('#result').get(0))
    socket.emit 'data', "\n"
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

    
