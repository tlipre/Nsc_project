$ ->
  socket = io()
  result = $('#result')
  regexBr = /\n/g
  $(document).keypress (e) ->
    if e.which == 13
      terminal = $('#terminal') 
      if terminal.is(":focus")
        socket.emit 'terminal', terminal.val()
        terminal.val('')
  socket.on 'terminal', (message)->
    message = message.replace "]0;","\n"
    message = message.replace regexBr,"<br>"
    #message = message.substr(0,message.lastIndexOf(']0;'))
    result.append "#{message}"


