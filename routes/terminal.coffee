CONTAINER_ID = '5e7b822bd765'
docker_stream = null

Docker = require 'dockerode'
docker = new Docker()
router = express.Router()
container = docker.getContainer CONTAINER_ID

commandDocker = (command)->
  docker_stream.write "#{command}\n"

container.start (err, data)->
  container.attach {stream: true, stdin:true, stdout:true, stderr:false}, (err, stream)->
    docker_stream = stream
    # docker_stream.on 'data', (message)->
    #   message = message.toString()
    #   io.emit 'terminal', message

router.get '/terminal', (req, res) ->
  res.render 'terminal'

io.on 'connection', (socket)->
  console.log('Have connection')
  socket.on 'terminal', (command)->
    commandDocker command

module.exports = router