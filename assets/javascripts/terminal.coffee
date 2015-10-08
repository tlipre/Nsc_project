$ ->
  editor = $('#editor')
  editor.focus()
  socket = io();
  socket.on 'connect', ()-> 
    term = new Terminal {
      cols: 80,
      rows: 24,
      useStyle: true,
      screenKeys: true,
      cursorBlink: true
    }
    socket.emit 'data', "\n"
    term.on 'data', (data)->
      socket.emit 'data', data
    term.on 'title', (title) ->
      document.title = title;
    term.open($('#result').get(0))
    term.write '\x1b[31mWelcome to term.js!\x1b[m\r\n'
    socket.on 'data', (data)->
      term.write data
    socket.on 'disconnect', ()->
      term.destroy()
  $('#save').click ()->
    #TODO: handler error(s)
    fileName = prompt 'Enter file name.', 'untitled'
    while fileName == ''
      fileName = prompt 'Enter file name again.', 'untitled'
    $.post  "/terminal", { code: editor.val(), fileName: fileName}

    
