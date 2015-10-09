e_classroom_schema = mongoose.Schema
  name: String
  key: String
  student_count: Number
  containers: [
    container_id: String
    owner: String
  ]
  # check_result : mongoose.Schema.Types.Mixed
,
  versionKey: false

botData = mongoose.model 'EClassroom', e_classroom_schema
