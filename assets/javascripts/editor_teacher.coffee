$ ->
  is_teacher_view = true
  editor = $('.editor')
  student = $('.docker')
  socket = io('/editor')
  book = $('#book')
  username = $('.username')
  aj = $('#aj')

  aj.click ()->
    username.text('AjJoob')
    editor.val("")
    is_teacher_view = true
  book.click ()->
    username.text('Book')
    is_teacher_view = false
  student.click ()->
    socket.emit 'request', 'student'
  socket.on 'student', (data)->
    if !is_teacher_view
      editor.val(data)


