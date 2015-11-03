chat_log_schema = mongoose.Schema
  e_classroom_id: type: String
  message: type: String
  sender: type: String, default: null
  timestamp: type: String, default: moment()
,
  versionKey: false


Chat_log = mongoose.model 'Chat_log', chat_log_schema