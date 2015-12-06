pty = require 'pty.js'
Docker = require 'dockerode'
docker = new Docker()
shortid = require 'shortid'

container_schema = mongoose.Schema
  container_id: type: String
  classroom_id: type: String
  text: type: String, default: null
  owner: type: String, default: null
  status: type: String, default: 'running'
  term: mongoose.Schema.Types.Mixed
,
  versionKey: false


container_schema.methods.create_stream = (callback)->
  success = true
  self = this
  container = docker.getContainer(self.container_id)
  container.start (err, data)->
    if err? 
      if err.reason isnt "container already started"
        success = false
        callback err
    if success
      if self.status isnt 'streaming'
        docker_socket[self.container_id] = pty.spawn 'docker', ["attach", self.container_id], 
          name: 'xterm-color',
          cols: 60,
          rows: 15,
          cwd: process.env.HOME,
          env: process.env
        docker_socket[self.container_id].on 'data', (data)->
          event_emitter.emit 'text_terminal', self.container_id, data
        self.status = 'streaming'
        self.save()
      callback null

container_schema.methods.update_owner = (owner)->
  this.owner = owner
  this.save()

Container = mongoose.model 'Container', container_schema
