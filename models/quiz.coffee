quiz_schema = mongoose.Schema
  classroom_name: type: String
  quiz_name: type: String
  item_count: type: Number
  items: mongoose.Schema.Types.Mixed
  timestamp: type: String, default: moment()

,
  versionKey: false


Quiz = mongoose.model 'Quiz', quiz_schema
