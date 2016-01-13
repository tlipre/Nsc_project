$ ->
  socket = io('/editor')


  editor = ace.edit("editor");
  ace.config.set 'basePath', '/javascripts/ace-editor/'
  editor.setTheme "ace/theme/monokai"
  editor.getSession().setMode "ace/mode/javascript"
  editor.setFontSize 18
  editor.setHighlightActiveLine false
  editor.setShowPrintMargin false

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



