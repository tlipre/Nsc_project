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
        console.log data
        $("#quiz-name").text(data.quiz_name)
        render_item data.item, $("#item-box")
      else
        alert(data.message)
  selected_choice = 0
  $("input:radio[name=ans]").click ()->
    selected_choice = $(this).val()

  item_sender.click (e)->
    e.preventDefault()
    $.post "../quiz/item", 
      "classroom_name": classroom_name, 
      "quiz_name": $("#quiz-name").text(),
      "item": $("#item").text(),
      "selected_choice": selected_choice
    , (data)->
      console.log data



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
  