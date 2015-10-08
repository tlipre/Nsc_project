CONTAINER_ID = '6c57d3d50745'
term = require('term.js');
fs = require 'fs'
pty = require('pty.js');
exec = require("child_process").exec
app.use(term.middleware());

pushFileToDocker = (path_to_file, destination, container_id, callback) ->
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

router.get '/terminal', (req, res) ->
  res.render 'terminal'

router.post '/terminal', (req, res) ->
  code = req.body.code
  fileName = 'test'
  fileType = 'py'
  destination = '/home'
  pathToFile = "#{process.cwd()}/public/uploads/#{fileName}.#{fileType}"
  fs.writeFile pathToFile, code, (err)->
    res.send err if err
    pushFileToDocker pathToFile, destination, CONTAINER_ID, (err)->
      res.send err if err
      res.send 'ok'
      


io.on 'connection', (socket)->
  console.log 'Have connection'

  term.on 'data', (data) -> 
    socket.emit 'data',data

  socket.on 'data', (data) ->
    term.write data

  socket.on 'disconnect', () ->
    #TODO: destroy
    console.log "Disconect"

module.exports = router