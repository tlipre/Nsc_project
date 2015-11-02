Container = mongoose.model 'Container'
Docker = require 'dockerode'
docker = new Docker()
async = require 'async'
shortid = require 'shortid'

e_classroom_schema = mongoose.Schema
  raw_name: String
  key: String
  student_count: Number
  name: String
  # check_result : mongoose.Schema.Types.Mixed
,
  versionKey: false

q = async.queue (task, callback) ->
  docker.createContainer {Image: task.image, Cmd: ['/bin/bash']}, (err, container)->
    return callback err if err
    callback null, container.id
  , 2

e_classroom_schema.pre 'save', (next)->
  this.name = _.kebabCase this.raw_name
  this.key = shortid.generate()
  mongoose.models["EClassroom"].findOne {raw_name: this.raw_name}, (err, data)->
    next(new Error('Name must be unique')) if data
    items = []
    for i in [1..this.student_count]
      items.push {image: 'ubuntu'}
    q.push items, (err, container_id)-> 
      return console.log err if err
      container = new Container({container_id: container_id, e_classroom_id: this._id})
      container.save()
      console.log "Finish create: " + container_id.green
    q.drain = ()->
      next()

EClassroom = mongoose.model 'EClassroom', e_classroom_schema
