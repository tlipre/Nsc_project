Container = mongoose.model 'Container'
Docker = require 'dockerode'
docker = new Docker()
async = require 'async'
shortid = require 'shortid'

classroom_schema = mongoose.Schema
  raw_name: String
  key: String
  name: String
  max_student: Number
  student_count: type: Number, default: 0
  students: type: Array, default: []
  teacher: mongoose.Schema.Types.Mixed
  # check_result : mongoose.Schema.Types.Mixed
,
  versionKey: false


q = async.queue ((task, callback) ->
  docker.createContainer {Image: task.image, Cmd: ['/bin/bash']}, (err, container)->
    if err
      callback err 
    else
      callback null, container.id
), 2
  
classroom_schema.methods.create_container = (callback)->
  self = this
  self.name = _.kebabCase self.raw_name
  self.key = shortid.generate()
  mongoose.models["Classroom"].findOne {raw_name: self.raw_name}, (err, data)->
    if data
      callback(new Error('Name must be unique'))
    else
      items = []
      for i in [1..self.max_student]
        items.push {image: 'ubuntu'}
      q.push items, (err, container_id)-> 
        container = new Container({container_id: container_id, classroom_id: self._id})
        container.save()
        console.log "Finish create: " + container_id.green
      q.drain = ()->
        callback()

Classroom = mongoose.model 'Classroom', classroom_schema
