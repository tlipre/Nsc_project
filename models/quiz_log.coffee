quiz_log_schema = mongoose.Schema
  classroom_name: type: String
  student: type: String
  selected_choice: type: String
  item: type: String
  timestamp: type: String, default: moment()
,
  versionKey: false


Quiz_log = mongoose.model 'Quiz_log', quiz_log_schema
