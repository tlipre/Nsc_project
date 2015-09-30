CONTAINER_ID = '5e7b822bd765'
docker_stream = null

fs = require 'fs'
Docker = require 'dockerode'
docker = new Docker()
exec = require("child_process").exec
router = express.Router()

pushFileToDocker = (path_to_file, destination, container_id, callback) ->
  command = "docker cp #{path_to_file} #{container_id}:#{destination}"
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

pullFileFromDocker = (path_to_file, destination, container_id, callback) ->
  command = "docker cp #{container_id}:#{path_to_file} #{destination} "
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

#TODO: finish this function
compileInDocker = (command, path_to_file, result_file)->
  docker_stream.write "#{command} #{path_to_file} > #{result_file}\n", ()->
  

container = docker.getContainer CONTAINER_ID
container.start (err, data)->
  container.attach {stream: true, stdin:true, stdout:true, stderr:false}, (err, stream)->
    # stream.pipe process.stdout
    docker_stream = stream

fileTypes = {'python': 'py'} #TODO: add some filetype(s) here

router.get '/compile/:language', (req, res) ->
  code = "for i in range(10):\n    print '1'+str(i)" #TODO: use code that send from ajax
  language = req.params.language
  fileType = fileTypes[language]
  return res.send "Our system not supports #{language}" if !fileType?

  fileName = "random"
  rawFile = "#{fileName}.#{fileType}"
  resultFile = "#{fileName}.result"
  destination = "/home"
  parentPath = "#{process.cwd()}/public/uploads/"
  pathToFile = "#{process.cwd()}/public/uploads/#{fileName}.#{fileType}"
  fs.writeFile pathToFile, code, (err)->
    return res.send err if err?
    pushFileToDocker pathToFile, destination, CONTAINER_ID, (err)->
      return res.send err if err?
      compileInDocker "python", "/home/#{rawFile}", resultFile
      pullFileFromDocker "#{destination}/#{resultFile}", "#{parentPath}/#{resultFile}", CONTAINER_ID, (err)->
        return res.send err if err?
        res.send 'success'

module.exports = router

sdf