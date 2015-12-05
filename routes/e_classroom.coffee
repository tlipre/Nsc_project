term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
exec = require("child_process").exec
async = require 'async'
cookie_parser = require('cookie').parse
User = mongoose.model 'User'
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

#docker rm $(docker ps -a -q --filter 'exited=0')
router = express.Router()

global.docker_socket = {}

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
      Container.findOne {classroom_id: classroom.id, owner: req.session.passport.user.username}, (err, container)->
        if container?
          container.create_stream (err)->
            if err
              res.send err
            else
              Chat_log.find {classroom_name: classroom.name}, (err, chat_log)->
                username = req.session.passport.user.username
                render_data = _.assign username: username, chat: chat_log, classroom: classroom, container_id: container.container_id
                res.render 'e_classroom_teacher', render_data
        else
          res.send 'you not belong here'
    else
      #for 404
      res.sendFile "#{process.cwd()}/public/html/404.html"

router.get '/:name/student-test', helper.check_role('student'), (req, res) ->
  name = req.params.name
  Classroom.findOne {name: name}, (err, classroom)->
    if classroom?
      Container.findOne {classroom_id: classroom.id, owner: req.session.passport.user.username}, (err, container)->
        if container?
          container.create_stream (err)->
            if err
              res.send err
            else
              Chat_log.find {classroom_name: classroom.name}, (err, chat_log)->
                username = req.session.passport.user.username
                render_data = _.assign username: username, chat: chat_log, classroom: classroom, container_id: container.container_id
                res.render 'e_classroom_student_test', render_data
        else
          res.send 'you have to enroll first'
    else
      #for 404
      res.sendFile "#{process.cwd()}/public/html/404.html"

router.get '/student', (req, res) ->
  res.render 'e_classroom_student'

router.get '/', (req, res) ->
  if req.session.passport isnt {}
    user = req.session.passport.user
    if user.in_classroom?
      return res.redirect "/e-classroom/#{user.in_classroom}/student-test"
  Classroom.find {}, (err, classrooms)->
    username = undefined
    if !_.isEmpty req.session.passport
      username = req.session.passport.user.username
    render_data = _.assign username: username, classrooms: classrooms
    res.render 'e_classroom_all', render_data

router.post '/enroll', (req, res) ->
  #TODO: prevent from someone that enrolled
  classroom_name = req.body.name
  key = req.body.key

  Classroom.findOne {name: classroom_name, key: key}, (err, classroom) ->
    if !classroom?
      res.send 'wrong password'
    else
      # if req.session.passport.user.in_classroom?
      if false
        res.send 'you have to enroll only 1 class at a time.'
      else
        Container.findOne {classroom_id: classroom.id, owner: null}, (err, container) ->
          if !container?
            res.send 'this classroom is full'
          else
            User.findOne {username: req.session.passport.user.username}, (err, user)->
              container.update_owner user.username
              user.enroll classroom.name
              req.session.passport.user.in_classroom = classroom.name
              user_temp = _.cloneDeep req.session.passport.user
              classroom.add_student user_temp, container.container_id

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

io.use (socket, next)->
  session_middleware(socket.request, socket.request.res, next)

chat_room = io.of('/chat')
editor_room = io.of('/editor')
terminal_room = io.of('/terminal')

editor_room.on 'connection', (socket)->
  socket.on 'request_container', (data)->
    session = socket.request.session
    Container.findOne {owner: session.passport.user.username}, (err, container)->
      if container?
        socket.verified = true
        socket.room = container.container_id
        socket.join socket.room
        editor_room.to(socket.room).emit('init', container.text)

  socket.on 'request_container_teacher', (data)->
    #TODO: AUTH teacher
    Container.findOne {container_id: data}, (err, container)->
      socket.room = container.container_id
      socket.join socket.room
      editor_room.to(socket.room).emit('type_student', container.text)

  socket.on 'type_student', (data)->
    session = socket.request.session
    Container.findOne {owner: session.passport.user.username}, (err, container)->
      if container?
        container.text = data
        container.save()
        editor_room.to(socket.room).emit('type_student', data)

  socket.on 'type_teacher', (data)->
    #TODO: AUTH teacher
    session = socket.request.session
    Container.findOne {container_id: socket.room}, (err, container)->
      if container?
        container.text = data
        container.save()
      editor_room.to(socket.room).emit('type_teacher', data)

chat_room.on 'connection', (socket)->
  socket.on 'join_room', (data)->
    #TODO: AUTH
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

Container.find {status: 'streaming'}, (err, containers)->
  for container in containers
    console.log 'streaming', container.container_id
    docker_socket[container.container_id] = pty.spawn 'docker', ['attach', container.container_id], 
      name: 'xterm-color',
      cols: 80,
      rows: 30,
      cwd: process.env.HOME,
      env: process.env
    do(container)->
      docker_socket[container.container_id].on 'data', (data)->
        event_emitter.emit 'text_terminal', container.container_id, data


router.get '/test', (req, res)->
  console.log Object.keys docker_socket

event_emitter.on 'text_terminal', (room, data)->
  terminal_room.to(room).emit('data', data)

terminal_room.on 'connection', (socket)->
  socket.on 'request_terminal', (container_id)->
    #TODO: AUTH
    # session = socket.request.session
    Container.findOne {container_id: container_id}, (err, container)->
      if container?
        socket.room = container.container_id
        socket.join socket.room

  socket.on 'data', (container_id, data) ->
    if docker_socket[container_id]?
      docker_socket[container_id].write data
  # socket.on 'disconnect', () ->
  #   #TODO: destroy
  #   dev.highlight 'disconnect'



module.exports = router