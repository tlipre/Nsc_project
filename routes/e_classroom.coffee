term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
exec = require("child_process").exec
async = require 'async'
cookie_parser = require('cookie').parse

Chat_log = mongoose.model 'Chat_log'
Classroom = mongoose.model 'Classroom'
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

router.post '/create', helper.check_role('teacher'), (req, res)->
  classroom = new Classroom()
  classroom.max_student = req.body.max_student
  classroom.raw_name = req.body.raw_name
  classroom.teacher = req.session.passport.user
  classroom.create_container (err)->
    if err
      res.send err.message
    else
      classroom.save()
      res.redirect "#{classroom.name}/teacher"

router.get '/:name/teacher', helper.check_role('teacher'), (req, res)->
  name = req.params.name
  Classroom.findOne {name: name}, (err, classroom)->
    if classroom?
      Chat_log.find {classroom_name: classroom.name}, (err, chat_log)->
        username = req.session.passport.user.username
        render_data = _.assign username: username, chat: chat_log, classroom: classroom
        res.render 'e_classroom_teacher', render_data
    else
      #for 404
      res.sendFile "#{process.cwd()}/public/html/404.html"

router.get '/:name/student-test', helper.check_role('student'), (req, res) ->
  name = req.params.name
  Classroom.findOne {name: name}, (err, classroom)->
    if classroom?
      Chat_log.find {classroom_name: classroom.name}, (err, chat_log)->
        username = req.session.passport.user.username
        render_data = _.assign username: username, chat: chat_log, classroom: classroom
        res.render 'e_classroom_student_test', render_data
    else
      #for 404
      res.sendFile "#{process.cwd()}/public/html/404.html"
  # name = req.params.name
  # Classroom.findOne {name: name}, (err, classroom)->
  #   if classroom?
  #     Chat_log.find {classroom_name: classroom.name}, (err, chat_log)->
  #       username = req.session.passport.user.username
  #       render_data = _.assign username: username, chat: chat_log
  #       res.render 'e_classroom_student_test', render_data

router.get '/student', (req, res) ->
  res.render 'e_classroom_student'


router.get '/', (req, res) ->
  Classroom.find {}, (err, classrooms)->
    username = undefined
    if !_.isEmpty req.session.passport
      username = req.session.passport.user.username
    render_data = _.assign username: username, classrooms: classrooms
    res.render 'e_classroom_all', render_data

router.post '/enroll', (req, res) ->
  #TODO: prevent from someone that enrolled

  #get classroom name from modal
  classroom_name = 'soa2'
  key = req.body.key

  Classroom.findOne {raw_name: classroom_name, key: key}, (err, classroom) ->
    if !classroom?
      res.send 'wrong password'
    else
      Container.findOne {classroom_id: classroom.id, owner: null}, (err, container) ->
        if !container?
          res.send 'this classroom is full'
        else
          container.owner = req.session.passport.user.username
          container.save()

          user = _.cloneDeep req.session.passport.user
          user.container_id = container.id
          classroom.students.push user
          classroom.student_count++
          classroom.save()

          res.redirect "#{classroom.name}/student-test"

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

chat_room.on 'connection', (socket)->
  socket.on 'join room', (data)->
    #TODO: AUTH by session
    session = socket.request.session
    if true
      socket.verified = true
      socket.room = data
      socket.join data

  socket.on 'message', (data)->
    if socket.verified
      data.classroom_name = socket.room
      chat = new Chat_log(data)
      chat.save()
      data = {message: chat.message, sender: chat.sender, timestamp: chat.timestamp}
      chat_room.to(socket.room).emit('message', data)
    else
      console.log 'someone try to hack'

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