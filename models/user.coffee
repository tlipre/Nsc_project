user_schema = mongoose.Schema
  username: type: String
  password: type: String
  status: type: String, default: 'login'
  role: type: String, default: 'student'
,
  versionKey: false

User = mongoose.model 'User', user_schema
