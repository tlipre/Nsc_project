e_classroom_schema = mongoose.Schema
  name: String
  key: String
  student_count: Number
  # check_result : mongoose.Schema.Types.Mixed
,
  versionKey: false

EClassroom = mongoose.model 'EClassroom', e_classroom_schema
