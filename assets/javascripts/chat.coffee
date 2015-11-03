$ ->
  typing_box = $('#typing-box')
  chat_box = $('.chat-box')
  socket = io('/chat');
  room_name = prompt("What's room's name?")

  socket.on 'connect', ()->
    socket.emit 'join room', room_name

  typing_box.bind 'keypress', (e)->
    if e.keyCode == 13
      socket.emit 'message', {message: typing_box.val(), sender: $('#username').text()}
      typing_box.val('')
  
  socket.on 'message', (data)->
    chat_box.append "<p><span class='name'>#{data.sender}: </span><span>#{data.message}</span></p>"