$ ->
  is_teacher_view = true
  editor = $('.editor')
  student = $('.docker')
  socket = io('/editor')
  book = $('#book')
  aj = $('#aj')

  aj.click ()->

  book.click ()->
    is_teacher_view = false
  student.click ()->
    socket.emit 'request', 'student'
  socket.on 'student', (data)->
    editor.val(data)

