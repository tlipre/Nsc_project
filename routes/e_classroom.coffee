term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
shortid = require 'shortid'
exec = require("child_process").exec
async = require 'async'
cookie_parser = require('cookie').parse

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

q = async.queue (task, callback) ->
  docker.createContainer {Image: task.image, Cmd: ['/bin/bash']}, (err, container)->
    return callback err if err
    callback null, container.id
  , 2

router.get '/create', helper.check_role, (req, res)->
  res.render 'e_classroom_create'

router.get '/booking_container/:container_id', helper.check_auth,  (req, res)->
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

router.post '/create', (req, res)->
  student_count = req.body.student_count
  name = req.body.name
  key = shortid.generate()
  e_classroom = new EClassroom()
  e_classroom.student_count = student_count
  e_classroom.name = name
  e_classroom.key = key
  items = []
  for i in [1..student_count]
    items.push {image: 'ubuntu'}
  q.push items, (err, container_id)-> 
    return console.log err if err
    container = new Container({container_id: container_id, e_classroom_id: e_classroom._id})
    container.save()
    console.log "Finish create: " + container_id.green
  q.drain = ()->
    e_classroom.save()
    res.redirect "teacher/#{key}"

router.get '/teacher/:key', (req, res)->
  key = req.params.key
  res.render 'e_classroom_teacher', {key: key}

router.get '/student', (req, res) ->
  res.render 'e_classroom_student'

# classroom_student
router.get '/student-test', (req, res) ->
  res.render 'classroom_sudent'

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

router.get '/session', (req, res) ->
  redis_store.get '1moAk3Uys0G16Q7HcCZRXLJZ3j0uE4rB', (err, session)->
    console.log session
  res.send 'ok'

tmn = io.of('/terminal')

tmn.use (socket, next) ->
  cookie = cookie_parser socket.request.headers.cookie
  dev.highlight cookie
  next()

tmn.on 'connection', (socket)->
  term.on 'data', (data) -> 
    socket.emit 'data',data

  socket.on 'data', (data) ->
    term.write data

  socket.on 'disconnect', () ->
    #TODO: destroy
    console.log "Disconect"

module.exports = router