$ ->
  socket = io()
  result = $('#result')
  $(document).keypress (e) ->
    if e.which == 13
      terminal = $('#terminal') 
      if terminal.is(":focus")
        socket.emit 'terminal', terminal.val()
        terminal.val('')
  socket.on 'terminal', (message)->
    result.append "<li>#{message}</li>"


