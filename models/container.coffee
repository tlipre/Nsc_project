pty = require 'pty.js'

container_schema = mongoose.Schema
  container_id: type: String
  classroom_id: type: String
  text: type: String, default: null
  owner: type: String, default: null
  status: type: String, default: 'running'
  term: mongoose.Schema.Types.Mixed
,
  versionKey: false

container_schema.methods.create_stream = ()->
  docker_socket[this.container_id] = pty.spawn 'docker', ["attach", this.container_id], 
    name: 'xterm-color',
    cols: 80,
    rows: 30,
    cwd: process.env.HOME,
    env: process.env
  docker_socket[this.container_id].on 'data', (data)->
    event_emitter.emit 'text_terminal', this.container_id, data
  

Container = mongoose.model 'Container', container_schema
