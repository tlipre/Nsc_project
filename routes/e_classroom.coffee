term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
exec = require("child_process").exec
cookie_parser = require('cookie').parse
User = mongoose.model 'User'
Chat_log = mongoose.model 'Chat_log'
Classroom = mongoose.model 'Classroom'
Container = mongoose.model 'Container'
Quiz = mongoose.model 'Quiz'

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

router.post '/quiz', helper.check_role('teacher'), (req, res)->
  console.log req.body

  quiz = new Quiz(req.body)
  dev.highlight quiz
  # quiz.save (err)->
  #   return res.send err if err 
  #   res.send 'ok'

router.get '/quiz', helper.check_role('teacher'), (req, res)->
  Quiz.find {classroom_name: req.params.classroom_name}, (err, quizzes)->
    if quizzes?
      res.json quizzes


router.post '/quiz/item', (req, res)->
  quiz_name = req.body.quiz_name
  classroom_name = req.body.classroom_name
  item = req.body.item
  selected_choice = req.body.selected_choice
  Quiz.findOne {classroom_name: classroom_name, quiz_name: quiz_name}, (err, quiz)->
    if quiz?
      if quiz.corrected_choice[item] == selected_choice
        #point ++
        res.send 'ok'
      #send another item


router.get '/create', helper.check_role('teacher'), (req, res)->
  username = req.session.passport.user.username
  res.render 'e_classroom_create', {username: username}


router.post '/create', helper.check_role('teacher'), (req, res)->
  classroom = new Classroom()
  classroom.max_student = req.body.max_student
  classroom.raw_name = req.body.raw_name
  classroom.teacher = req.session.passport.user
  classroom.teacher_name = req.session.passport.user.username
  classroom.create_container (err)->
    if err
      res.send err.message
    else
      username = req.session.passport.user.username
      User.findOne {username: username}, (err, user)->
        user.in_classroom = classroom.name
        user.save()
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

router.get '/:name/teacher/student', (req, res)->
  name = req.params.name
  Classroom.findOne {name: name}, (err, classroom)->
    res.render 'e_classroom_teacher_student', {classroom: classroom}

router.get '/:name/student', helper.check_role('student'), (req, res) ->
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
                res.render 'e_classroom_student', render_data
        else
          res.send 'you have to enroll first'
    else
      #for 404
      res.sendFile "#{process.cwd()}/public/html/404.html"

router.get '/', helper.check_auth, (req, res) ->
  if !_.isEmpty req.session.passport
    username = req.session.passport.user.username
    User.findOne {username: username}, (err, user)->
      if user.in_classroom?
          res.redirect "/e-classroom/#{user.in_classroom}/#{user.role}"
      else
        Classroom.find {}, (err, classrooms)->
          render_data = _.assign user: user, username: username, classrooms: classrooms
          res.render 'e_classroom_all', render_data
  else
    Classroom.find {}, (err, classrooms)->
      render_data = _.assign classrooms: classrooms
      res.render 'e_classroom_all', render_data

router.post '/enroll', helper.check_role('student'), (req, res) ->
  #TODO: prevent from someone that enrolled
  classroom_name = req.body.name
  key = req.body.key

  Classroom.findOne {name: classroom_name, key: key}, (err, classroom) ->
    if !classroom?
      res.send 'wrong password'
    else
      User.findOne {username: req.session.passport.user.username}, (err, user)->
        if user.in_classroom
          res.send 'you can only enroll only 1 class at the time.'
        else
          Container.findOne {classroom_id: classroom.id, owner: null}, (err, container) ->
            if !container?
              res.send 'this classroom is full'
            else
                container.update_owner user.username
                user.enroll classroom.name
                user_temp = _.cloneDeep req.session.passport.user
                classroom.add_student user_temp, container.container_id
                res.redirect "#{classroom.name}/student"

router.post '/editor', (req, res) ->
  code = req.body.code
  file_name = req.body.file_name
  container_id = req.body.container_id
  destination = '/'
  path = "#{process.cwd()}/public/uploads/docker/#{container_id}"
  fs.existsSync(path) || fs.mkdirSync(path);
  fs.writeFile "#{path}/#{file_name}", code, (err)->
    return res.send err if err
    push_file "#{path}/#{file_name}", destination, container_id, (err)->
      return res.send err if err
      res.send 'ok'

io.use (socket, next)->
  session_middleware(socket.request, socket.request.res, next)

chat_room = io.of('/chat')
editor_room = io.of('/editor')
terminal_room = io.of('/terminal')

editor_room.on 'connection', (socket)->
  socket.on 'request_container', (data)->
    #for student or teacher request his own container
    session = socket.request.session
    Container.findOne {owner: session.passport.user.username}, (err, container)->
      if container?
        socket.verified = true
        socket.room = container.container_id
        socket.join socket.room
        editor_room.to(socket.room).emit('init', container.text)

  socket.on 'toggle', ()->
    session = socket.request.session
    Classroom.findOne {teacher_name: session.passport.user.username}, (err, classroom)->
      classroom.toggle_status()
      if classroom.status != 'allowed'
        editor_room.to(socket.room).emit 'error', 'disallowed'

  socket.on 'request_container_student', (data)->
    #for student watch teacher
    session = socket.request.session
    User.findOne {username: session.passport.user.username}, (err, user)->
      Classroom.findOne {name: user.in_classroom}, (err, classroom)->
        if classroom.status == 'allowed'
          container_id = classroom.teacher.container_id
          Container.findOne {container_id: container_id}, (err, container)->
            socket.room = container_id
            socket.join socket.room
            editor_room.to(socket.room).emit('init', container.text)
        else
          editor_room.emit 'error', 'disallowed'


  socket.on 'request_container_teacher', (data)->
    #for teacher watch student
    #TODO: AUTH teacher
    Container.findOne {container_id: data}, (err, container)->
      socket.leave socket.room
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
      if data.sender.indexOf('Aj') == 0
        data.is_teacher = true
      else
        data.is_teacher = false
      chat = new Chat_log(data)
      chat.save()
      data = {is_teacher: chat.is_teacher, message: chat.message, sender: chat.sender, timestamp: chat.timestamp}
      chat_room.to(socket.room).emit('message', data)
    
  socket.on 'ask_for_help', (user)->
    chat_room.to(socket.room).emit('ask_for_help', user)

Container.find {status: 'streaming'}, (err, containers)->
  for container in containers
    do(container)->
      docker_container = docker.getContainer(container.container_id)
      docker_container.start (err, data)->
        console.log 'streaming', container.container_id
        docker_socket[container.container_id] = pty.spawn 'docker', ['attach', container.container_id], 
          name: 'xterm-color',
          cols: 60,
          rows: 15,
          cwd: process.env.HOME,
          env: process.env        
        docker_socket[container.container_id].on 'data', (data)->
          event_emitter.emit 'text_terminal', container.container_id, data


router.get '/test', (req, res)->
  console.log Object.keys docker_socket

event_emitter.on 'text_terminal', (room, data)->
  terminal_room.to(room).emit('data', data)

terminal_room.on 'connection', (socket)->
  socket.on 'request_terminal', (container_id)->
    #TODO: AUTH
    Container.findOne {container_id: container_id}, (err, container)->
      if container?
        if socket.room?
          socket.leave socket.room
        socket.room = container.container_id
        socket.join socket.room

  socket.on 'data', (container_id, data) ->
    if docker_socket[container_id]?
      docker_socket[container_id].write data
  # socket.on 'disconnect', () ->
  #   #TODO: destroy
  #   dev.highlight 'disconnect'



module.exports = router