$ ->
  socket = io('/editor')

  editor = ace.edit("editor");
  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false
  classroom_name = get_room_name()

  item_sender = $("#item-sender")
  # $('#myModal').modal('show')
  # $('#myModal').modal('hide') 

  socket.on 'connect', ()->
    socket.emit 'request_container'

  editor.on "change", (e)->
    if (editor.curOp && editor.curOp.command.name)
      #if change by user not programmatically
      socket.emit 'type_student', editor.getValue()

  socket.on 'type_teacher', (data)->
    editor.setValue data
    
  socket.on 'init', (data)->
    editor.setValue data

  $.get "../quiz?classroom_name="+classroom_name,
    (data)->
      if data.status is 'ok'
        $("#quiz-name").text(data.quiz_name)
        render_item data.item, $("#item-box")
        $('#myModal').modal('show')
      # else
        # alert(data.message)

  item_sender.click (e)->
    $('#myModal').modal('hide')
    $('body').removeClass('modal-open');
    $('.modal-backdrop').remove();
    $.post "../quiz/item", 
      "classroom_name": classroom_name, 
      "quiz_name": $("#quiz-name").text(),
      "item": $("#item").text(),
      "selected_choice": $("input[name=ans]:checked").val()
    , (data)->
      if data['status'] is 'next'
          $.get "../quiz?classroom_name="+classroom_name,
            (data)->
              if data.status is 'ok'
                $("#quiz-name").text(data.quiz_name)
                render_item data.item, $("#item-box")
                $('#myModal').modal('show')
      else
        alert(data['status'])



render_item = (item, item_box)->
  item_box.find("#item").text(item.item)
  item_box.find("#question").text(item.question)
  item_box.find("#ans-1").text(item.choices[0])
  item_box.find("#ans-2").text(item.choices[1])
  item_box.find("#ans-3").text(item.choices[2])
  item_box.find("#ans-4").text(item.choices[3])

get_room_name = ()->
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher
  current_url = window.location.href
  
  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')
  
  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)
  return room_name
  