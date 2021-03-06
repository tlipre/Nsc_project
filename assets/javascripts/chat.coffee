$ ->
  typing_box = $('#typing-box')
  chat_box = $('.chat-box')
  socket = io('/chat');

  room_name = get_room_name()

  socket.on 'connect', ()->
    socket.emit 'join_room', room_name

  #bind enter key
  typing_box.bind 'keypress', (e)->
    if e.keyCode == 13
      socket.emit 'message', {message: typing_box.val(), sender: $('#username').text()}
      typing_box.val('')
  
  socket.on 'message', (data)->
    if data.is_teacher
      chat_box.append "<p><span class='name'>#{data.sender}: </span><span>#{data.message}</span></p>"
    else
      chat_box.append "<p><span class='name black-font'>#{data.sender}: </span><span>#{data.message}</span></p>"

  $('#ask-for-help').click ()->
    socket.emit 'ask_for_help', $('#username').text()

  socket.on 'ask_for_help', (user)->
    if user != $('#username').text()
      alert("#{user} need help.")

get_room_name = ()->
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher
  current_url = window.location.href
  
  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')
  
  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)
  return room_name