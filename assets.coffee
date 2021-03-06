module.exports = (assets) ->
  assets.root = __dirname
  assets.addCss '/public/stylesheets/bootstrap/css/bootstrap.css'
  assets.addCss '/assets/stylesheets/layout.styl'
  assets.addCss '/assets/stylesheets/e_classroom.styl', 'e_classroom'
  assets.addCss '/assets/stylesheets/style.styl', 'style'

  assets.addJs '/public/javascripts/jquery-1.11.3.js'
  assets.addJs '/public/stylesheets/bootstrap/js/bootstrap.js'

  assets.addJs '/assets/javascripts/terminal.coffee', 'terminal'
  assets.addJs '/public/javascripts/socket.io-1.2.0.js', 'socket'
  assets.addJs '/assets/javascripts/chat.coffee', 'chat'
  assets.addJs '/assets/javascripts/style.coffee', 'style'
  assets.addJs '/assets/javascripts/editor.coffee', 'editor'
  assets.addJs '/assets/javascripts/editor_teacher.coffee', 'editor_teacher'
  assets.addJs '/assets/javascripts/e_classroom_create.coffee', 'e_classroom_create'
  assets.addJs '/assets/javascripts/student_view.coffee', 'student_view'
  assets.addJs '/assets/javascripts/e_classroom.coffee', 'e_classroom'
  assets.addJs '/public/javascripts/ace-editor/ace.js', 'editor'
  assets.addJs '/public/javascripts/ace-editor/ace.js', 'editor_teacher'
  assets.addJs '/public/javascripts/ace-editor/ace.js', 'student_view'

