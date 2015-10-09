CONTAINER_ID = '6c57d3d50745'
term = require 'term.js'
fs = require 'fs'
pty = require 'pty.js'
shortid = require 'shortid'
exec = require("child_process").exec
EClassroom = mongoose.model 'EClassroom'

app.use term.middleware()

push_file = (path_to_file, destination, container_id, callback) ->
  command = "docker cp #{path_to_file} #{container_id}:#{destination}"
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

term = pty.spawn 'docker', ["attach", CONTAINER_ID], 
  name: 'xterm-color',
  cols: 80,
  rows: 30,
  cwd: process.env.HOME,
  env: process.env

router = express.Router()

router.get '/create', (req, res)->
  res.render 'e_classroom_create'

router.post '/create', (req, res)->
  student_count = req.body.student_count
  name = req.body.name
  key = shortid.generate()
  e_classroom = new EClassroom()
  e_classroom.student_count = student_count
  e_classroom.name = name
  e_classroom.key = key
  e_classroom.containers.push {container_id: "something", owner: "null"}
  e_classroom.save()
  res.json req.body
  # res.send 'ok'

router.get '/teacher', (req, res)->
  res.render 'e_classroom_teacher'

router.get '/student', (req, res) ->
  res.render 'e_classroom_student'

router.post '/student', (req, res) ->
  code = req.body.code
  file_name = req.body.file_name
  file_type = 'py'
  destination = '/home'
  path = "#{process.cwd()}/public/uploads/#{file_name}.#{file_type}"
  fs.writeFile path, code, (err)->
    res.send err if err
    pushFileToDocker path, destination, CONTAINER_ID, (err)->
      res.send err if err
      res.send 'ok'
      


io.on 'connection', (socket)->
  term.on 'data', (data) -> 
    socket.emit 'data',data

  socket.on 'data', (data) ->
    term.write data

  socket.on 'disconnect', () ->
    #TODO: destroy
    console.log "Disconect"

module.exports = router