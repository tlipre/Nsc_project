$ ->
  socket = io('/editor')
  docker = $('.docker')
  status_changer = $('#status-changer')
  editor = ace.edit("editor-teacher")
  quiz_creator = $('#quiz-creator')
  quiz_tab = $('#quiz-tab')
  new_quiz = $('#new-quiz')
  create_quiz_page = $('#create-quiz-page')
  home_quiz_page = $('#home-quiz-page')
  item_appender = $('#item-appender')

  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false
  editor.$blockScrolling = Infinity

  current_view = $("#current-view")
  current_profile_picture = $("#current-profile-picture")
  classroom_name = get_room_name()

  new_quiz.click ()->
    #new quiz
    create_quiz_page.show()
    home_quiz_page.hide()

  item_appender.click ()->
    $('#item-count').val(parseInt($('#item-count').val())+1)
    item_count = $('#item-count').val()
    $('.quiz-question').append("<article>
      <div class='row'>
        <div class='col-md-2'>
          <p>คำถามที่ #{item_count}</p>
        </div>
        <div class='col-md-10'>
          <input id='item#{item_count}' type='text' class='form-control'>
        </div>
      </div>
      <div class='row choice'>
        <div class='col-md-2'>
          <input checked value='1' name='corrected_choice#{item_count}' type='radio' style='margin-right:10px;'>
          <span>A.</span>
        </div>
        <div class='col-md-10'>
          <input id='choice1_#{item_count}' type='text' class='form-control'>
        </div>   
      </div>
      <div class='row choice'>
        <div class='col-md-2'>
          <input value='2' name='corrected_choice#{item_count}' type='radio' style='margin-right:10px;'>
          <span>B.</span>
        </div>
        <div class='col-md-10'>
          <input id='choice2_#{item_count}' type='text' class='form-control'>
        </div>   
      </div>
      <div class='row choice'>
        <div class='col-md-2'>
          <input value='3' name='corrected_choice#{item_count}' type='radio' style='margin-right:10px;'>
          <span>C.</span>
        </div>
        <div class='col-md-10'>
          <input id='choice3_#{item_count}' type='text' class='form-control'>
        </div>   
      </div>
      <div class='row choice'>
        <div class='col-md-2'>
          <input value='4' name='corrected_choice#{item_count}' type='radio' style='margin-right:10px;'>
          <span>D.</span>
        </div>
        <div class='col-md-10'>
          <input id='choice4_#{item_count}' type='text' class='form-control'>
        </div>   
      </div>
    </article>")

  quiz_tab.click ()->
    #get all quiz
    $.get "../quiz?classroom_name="+classroom_name,
      (data)->
        console.log data


  quiz_creator.click ()->
    quiz_name = $('#quiz-name').val()
    item_count = $('#item-count').val()
    time = $('#time-minute').val()*60+parseInt($('#time-second').val())
    items = {}
    corrected_choice = []
    for i in [1..item_count]
      corrected_choice.push $("input[name=corrected_choice#{i}]:checked").val()
      choices = [$('#choice1_'+i).val(), $('#choice2_'+i).val(), $('#choice3_'+i).val(), $('#choice4_'+i).val()]
      items[i] = {item: i, question: $('#item'+i).val(), choices: choices}
    $.post "../quiz",
      data: JSON.stringify
        classroom_name: classroom_name, 
        quiz_name: quiz_name, 
        time: time,
        item_count: item_count,
        corrected_choice: corrected_choice
        items: items
      (data)->
        alert data

  socket.on 'connect', ()->
    socket.emit 'request_container'

  status_changer.click ()->
    if status_changer.hasClass('red')
      status_changer.removeClass('red')
      status_changer.val("Allowed")
    else
      status_changer.addClass('red')
      status_changer.val("Disallowed")
    socket.emit 'toggle'

  docker.click ()->
    #MTODO: loading animation
    container_id = $(this).data('id')
    container_owner = $(this).data('owner')
    socket.emit 'request_container_teacher', container_id    
    current_view.text container_owner
    current_profile_picture.attr 'src', "/uploads/profile_picture/#{container_owner}.jpg"

  editor.on "change", (e)->
    if (editor.curOp && editor.curOp.command.name) 
      socket.emit 'type_teacher', editor.getValue()

  socket.on 'type_student', (data)->
    editor.setValue(data)

  socket.on 'init', (data)->
    editor.setValue data

get_room_name = ()->
  # http://localhost:3000/e-classroom/soa-for-programmer/teacher
  current_url = window.location.href
  
  path = "e-classroom"
  start_index = current_url.indexOf(path)+path.length+1
  end_index = current_url.lastIndexOf('/')
  
  # 'soa-for-programmer'
  room_name = current_url.slice(start_index, end_index)
  return room_name
  

