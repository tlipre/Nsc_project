container_schema = mongoose.Schema
  container_id: type: String
  e_classroom_id: type: String
  text: type: String, default: null
  owner: type: String, default: null
  status: type: String, default: 'running'
,
  versionKey: false

Container = mongoose.model 'Container', container_schema
