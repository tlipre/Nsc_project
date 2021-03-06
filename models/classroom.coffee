Container = mongoose.model 'Container'
Docker = require 'dockerode'
docker = new Docker()
async = require 'async'
shortid = require 'shortid'
pty = require 'pty.js'

classroom_schema = mongoose.Schema
  raw_name: String
  key: String
  name: String
  max_student: Number
  student_count: type: Number, default: 0
  students: type: Array, default: []
  teacher: mongoose.Schema.Types.Mixed
  teacher_name: String
  status: type:String, default: 'allowed'
  # check_result : mongoose.Schema.Types.Mixed
,
  versionKey: false


q = async.queue ((task, callback) ->
  if config.have_docker
    docker.createContainer {OpenStdin:true,Tty:true, Cmd: ['/bin/bash'], Image: task.image}, (err, container)->
      container.start (err, data) ->
        if err
          callback err 
        else
          callback null, container.id
  else 
    callback null, 'has_no_docker'
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
      for i in [1..self.max_student+1]
        items.push {image: 'book/compiler'}
      q.push items, (err, container_id)->
        container = new Container({container_id: container_id, classroom_id: self._id, room: shortid.generate()})
        container.save()
        console.log "Finish create: " + container_id.green
      q.drain = ()->
        #container for teacher
        Container.findOne {classroom_id: self._id}, (err, container)->
          container.owner = self.teacher.username
          container.save()
          self.teacher.container_id = container.container_id
          callback()

classroom_schema.methods.add_student = (student, container_id)->
  student.container_id = container_id
  this.students.push student
  this.student_count++
  this.save()

classroom_schema.methods.toggle_status = ()->
  if this.status is 'allowed'
    this.status = 'disallowed'
  else
    this.status = 'allowed'
  this.save()

Classroom = mongoose.model 'Classroom', classroom_schema
