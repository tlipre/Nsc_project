$ ->
  typing_box = $('#typing-box')
  chat_box = $('.chat-box')
  socket = io('/chat');
  current_url = window.location.href
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher

  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')

  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)

  socket.on 'connect', ()->
    socket.emit 'join room', room_name

  #bind enter key
  typing_box.bind 'keypress', (e)->
    if e.keyCode == 13
      socket.emit 'message', {message: typing_box.val(), sender: $('#username').text()}
      typing_box.val('')
  
  socket.on 'message', (data)->
    chat_box.append "<p><span class='name'>#{data.sender}: </span><span>#{data.message}</span></p>"