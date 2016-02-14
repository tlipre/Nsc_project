$ ->
  socket_terminal = io('/terminal');
  editor = ace.edit("editor-student-view")
  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false

  container_id = $("#terminal").data("container-id")
  socket_terminal.on 'connect', ()->
    socket_terminal.emit 'request_terminal', container_id
  term = new Terminal {
    cols: 60,
    rows: 15,
    useStyle: true,
    screenKeys: true,
    cursorBlink: true
  }
  term.open($('#terminal').get(0))
  socket_terminal.on 'data', (data)->
    term.write data
  socket_terminal.on 'disconnect', ()->
    term.destroy()

  socket_editor = io('/editor')
  socket_editor.on 'error', (data)->
    socket_editor.destroy()
    socket_terminal.destroy()
    alert("Teacher disallowed to watch.")
    window.close()
  socket_editor.on 'connect', ()->
    socket_editor.emit 'request_container_student'
  
  socket_editor.on 'type_teacher', (data)->
    editor.setValue data

  socket_editor.on 'init', (data)->
    editor.setValue data






    
