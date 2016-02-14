quiz_schema = mongoose.Schema
  classroom_name: type: String
  quiz_name: type: String
  item_count: type: Number
  students: type: Array, default: []
  items: mongoose.Schema.Types.Mixed
  timestamp: type: String, default: moment()
  corrected_choice: type: Array
  time: type: Number
,
  versionKey: false


Quiz = mongoose.model 'Quiz', quiz_schema
