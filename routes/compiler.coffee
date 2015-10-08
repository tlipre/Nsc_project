CONTAINER_ID = '5e7b822bd765'
docker_stream = null

fs = require 'fs'
Docker = require 'dockerode'
shortid = require 'shortid'
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
  command = "docker cp #{container_id}:#{path_to_file} #{destination}"
  console.log command
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

#TODO: finish this function
compileInDocker = (command, path_to_file, result_file, callback)->
  docker_stream.write "#{command} #{path_to_file} > #{result_file} 2>&1\n", ()->
    flag = null
    flagInterval = setInterval ()->
      flag = docker_stream.read()
      if flag != null
        if flag.toString().indexOf(":/")>-1
          callback()
          clearInterval flagInterval
    ,100

    


container = docker.getContainer CONTAINER_ID
container.start (err, data)->
  container.attach {stream: true, stdin:true, stdout:true, stderr:false}, (err, stream)->
    # stream.pipe process.stdout
    docker_stream = stream


router.get '/compile_docker', (req, res) ->
  res.render 'text_docker'

router.get '/state', (req, res) ->
  console.log docker_stream
  res.send docker_stream._readableState


fileTypes = {'python': 'py', 'node': 'js'} #TODO: add some filetype(s) here

router.post '/compile_docker', (req, res) ->
  # code = "for i in range(10):\n    print '1'+str(i)" #TODO: use code that send from ajax
  code = req.body.command
  language = req.body.language
  fileType = fileTypes[language]
  return res.send "Our system not supports #{language}" if !fileType?

  fileName = shortid.generate()
  rawFile = "#{fileName}.#{fileType}"
  resultFile = "#{fileName}.txt"
  destination = "/home"
  parentPath = "#{process.cwd()}/public/uploads"
  pathToFile = "#{process.cwd()}/public/uploads/#{fileName}.#{fileType}"
  fs.writeFile pathToFile, code, (err)->
    return res.send err if err?
    pushFileToDocker pathToFile, destination, CONTAINER_ID, (err)->
      return res.send err if err?
      compileInDocker language, "/home/#{rawFile}", resultFile, ()->
        pullFileFromDocker "#{destination}/#{resultFile}", "#{parentPath}/#{resultFile}", CONTAINER_ID, (err)->
          return res.send err if err?
          fs.readFile "#{parentPath}/#{resultFile}", (err, data)->
            res.json {data : data.toString()}

module.exports = router