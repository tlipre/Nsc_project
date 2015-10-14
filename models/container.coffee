container_schema = mongoose.Schema
  container_id: type: String
  e_classroom_id: type: String
  owner: type: String, default: null
  status: type: String, default: 'running'
,
  versionKey: false

container_schema.pre 'save', (next)->
  next()

Container = mongoose.model 'Container', container_schema
