term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
exec = require("child_process").exec
async = require 'async'
cookie_parser = require('cookie').parse

Chat_log = mongoose.model 'Chat_log'
EClassroom = mongoose.model 'EClassroom'
Container = mongoose.model 'Container'

app.use term.middleware()

push_file = (path_to_file, destination, container_id, callback) ->
  command = "docker cp #{path_to_file} #{container_id}:#{destination}"
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

term = pty.spawn 'docker', ["attach", config.container_id], 
  name: 'xterm-color',
  cols: 80,
  rows: 30,
  cwd: process.env.HOME,
  env: process.env

#docker rm $(docker ps -a -q --filter 'exited=0')
router = express.Router()


router.get '/booking_container/:container_id', helper.check_role('student'),  (req, res)->
  container_id = req.params.container_id
  Container.findOne {"container_id":container_id}, (err, container)->
    username = req.session.passport.user.username
    if !container?
      res.send 'This container is not existed.'
    else if container.owner? and container.owner isnt username
      res.send 'This container has owner already.'
    else if container.owner is username
      res.send 'This container belongs to you.'
    else
      container.owner = username
      container.save()
      res.send 'Complete booking.'

router.get '/create', helper.check_role('teacher'), (req, res)->
  res.render 'e_classroom_create'

router.post '/create', (req, res)->
  e_classroom = new EClassroom()
  e_classroom.student_count = req.body.student_count
  e_classroom.raw_name = req.body.raw_name
  e_classroom.save (err)->
    #TODO: Handle error
    if err
      console.log err
    res.redirect "#{e_classroom.name}/teacher"

router.get '/:name/teacher', helper.check_role('teacher'), (req, res)->
  name = req.params.name
  Chat_log.find {}, (err, chat_log)->
    username = req.session.passport.user.username
    render_data = _.assign username: username, chat: chat_log, key: 'test'
    res.render 'e_classroom_teacher', render_data

router.get '/student', (req, res) ->
  res.render 'e_classroom_student'

router.get '/:name/student-test', helper.check_role('student'), (req, res) ->
  Chat_log.find {}, (err, chat_log)->
    username = req.session.passport.user.username
    render_data = _.assign username: username, chat: chat_log
    res.render 'e_classroom_student_test', render_data

router.post '/student', (req, res) ->
  code = req.body.code
  file_name = req.body.file_name
  file_type = 'py'
  destination = '/home'
  path = "#{process.cwd()}/public/uploads/#{file_name}.#{file_type}"
  fs.writeFile path, code, (err)->
    res.send err if err
    push_file path, destination, config.container_id, (err)->
      res.send err if err
      res.send 'ok'

router.get '/session/:id', (req, res)->
  redis_store.get req.params.id, (err, session)->
    dev.highlight session
    res.send req.session

io.use (socket, next)->
  session_middleware(socket.request, socket.request.res, next)

chat_room = io.of('/chat')
editor_room = io.of('/editor')
terminal_room = io.of('/terminal')

chat_room.use (socket, next)->
  session = socket.request.session
  #TODO: AUTH STUFF HERE
  if false
  # if true
    console.log "AUTH FAILED"
  else
    next()

chat_room.on 'connection', (socket)->
  socket.on 'message', (data)->
    #TODO: AUTH AGAIN
    # session = socket.request.session
    chat = new Chat_log(data)
    chat.save()
    data = {message: chat.message, sender: chat.sender, timestamp: chat.timestamp}
    chat_room.emit 'message', data

editor_room.on 'connection', (socket)->
  socket.on 'message', (data)->
    editor_room.emit 'student', data
  socket.on 'request', (data)->
    editor_room.emit 'request1', data
  
terminal_room.on 'connection', (socket)->
  term.on 'data', (data) -> 
    socket.emit 'data',data

  socket.on 'data', (data) ->
    term.write data

  socket.on 'disconnect', () ->
    #TODO: destroy
    console.log "Disconect"

module.exports = router