CONTAINER_ID = '6c57d3d50745'
docker_stream = null

fs = require 'fs'
Docker = require 'dockerode'
shortid = require 'shortid'
docker = new Docker()
exec = require("child_process").exec
router = express.Router()

push_file = (path, destination, container_id, callback) ->
  command = "docker cp #{path} #{container_id}:#{destination}"
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

pull_file = (path, destination, container_id, callback) ->
  command = "docker cp #{container_id}:#{path} #{destination}"
  exec command, (err, stdout, stderr)->
    if err?
      callback(stderr)
    else
      callback()

#TODO: finish this function
compile = (command, path, result_file, callback)->
  docker_stream.write "#{command} #{path} > #{result_file} 2>&1\n", ()->
    flag = null
    flag_interval = setInterval ()->
      flag = docker_stream.read()
      if flag != null
        if flag.toString().indexOf(":/")>-1
          callback()
          clearInterval flag_interval
    ,100

    


container = docker.getContainer CONTAINER_ID
container.start (err, data)->
  container.attach {stream: true, stdin:true, stdout:true, stderr:false}, (err, stream)->
    # stream.pipe process.stdout
    docker_stream = stream


router.get '/compile_docker', (req, res) ->
  res.render 'text_docker'

file_types = {'python': 'py', 'node': 'js'} #TODO: add some file_type(s) here

router.post '/compile_docker', (req, res) ->
  # code = "for i in range(10):\n    print '1'+str(i)" #TODO: use code that send from ajax
  code = req.body.command
  language = req.body.language
  file_type = file_types[language]
  return res.send "Our system not supports #{language}" if !file_type?

  file_name = shortid.generate()
  raw_file = "#{file_name}.#{file_type}"
  result_file = "#{file_name}.txt"
  destination = "/home"
  parent_path = "#{process.cwd()}/public/uploads"
  path = "#{process.cwd()}/public/uploads/#{file_name}.#{file_type}"
  fs.writeFile path, code, (err)->
    return res.send err if err?
    push_file path, destination, CONTAINER_ID, (err)->
      return res.send err if err?
      #TODO: To something with how to compile 
      compile "python3", "/home/#{raw_file}", "/home/#{result_file}", ()->
        pull_file "#{destination}/#{result_file}", "#{parent_path}/#{result_file}", CONTAINER_ID, (err)->
          return res.send err if err?
          fs.readFile "#{parent_path}/#{result_file}", (err, data)->
            res.json {data : data.toString()}

module.exports = router