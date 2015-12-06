user_schema = mongoose.Schema
  username: type: String
  password: type: String
  status: type: String, default: 'login'
  role: type: String, default: 'student'
  in_classroom: type: String, default: null
,
  versionKey: false

user_schema.methods.enroll = (classroom_id)->
  this.in_classroom = classroom_id
  this.save()

User = mongoose.model 'User', user_schema
