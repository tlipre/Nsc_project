global.config = require('./config')[process.env.NODE_ENV || 'development']
global.express = require 'express' 
global.app = express()
global.colors = require 'colors'
global.mongoose = require 'mongoose'
global.Schema = mongoose.Schema
global._ = require 'lodash'
global.moment = require 'moment'
global.dev = require './libs/dev'
flash = require 'connect-flash'
path = require 'path'

bundle_up = require 'bundle-up3'
fs = require 'fs'
body_parser = require 'body-parser'
cookie_parser = require 'cookie-parser'
session = require 'express-session'
RedisStore = require('connect-redis')(session)
morgan = require 'morgan'

mongoose.connect 'mongodb://localhost/senior_project'
mongoose.connection.on 'error', (err) ->
  console.log "Mongoose error: #{err}".red


server = require('http').createServer(app)
global.io = require('socket.io')(server)

for file in fs.readdirSync './models'
  continue if file.search(/\.bak|\.disabled|^\./) > -1
  if file.search(/\.coffee/) < 0
    for file_sub in fs.readdirSync './models/' + file
      continue if file_sub.search(/\.bak|\.disabled|^\./) > -1
      require("./models/#{file}/#{file_sub}")
  else
    require("./models/#{file}")

#this global is makesense
global.passport = require './libs/passport'
global.helper = require './libs/helper'

app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade' 
app.use express.static "#{__dirname}/public"
app.use body_parser.json()
app.use body_parser.urlencoded {extended: true}
app.use morgan 'dev'
app.use cookie_parser()
app.use flash()
global.redis_store = new RedisStore
    host : 'localhost'
    port : '6379'
    pass : ''
global.session_middleware = session
  secret: "bookmamieo"
  store : redis_store
  cookie :
    maxAge : 6048000
  resave: true
  saveUninitialized: true
app.use session_middleware
app.use passport.initialize()
app.use passport.session()



#bundle_up css and js
bundle_up app, __dirname + '/assets' ,
  staticRoot: __dirname + '/public/'
  staticUrlRoot: '/'
  bundle: config.bundle_up.bundle
  minifyCss: config.bundle_up.minifyCss
  minifyJs: config.bundle_up.minifyJs
  

  
app.use require './routes/compiler'
app.use require './routes/member'
app.use require './routes/util'
app.use '/api', require './routes/api'
app.use '/e-classroom', require './routes/e_classroom'

# dev zone
app.use '/mamieo', require './routes/mamieo'
# end dev zone

#this must be the last one
app.use require './routes/handler'


#reading apps
# for file in fs.readdirSync './apps'
#   continue if file.search(/\.bak|\.disabled|^\./) > -1
#   if file.search(/\.coffee/) < 0
#     for file_sub in fs.readdirSync './apps/' + file
#       continue if file_sub.search(/\.bak|\.disabled|^\./) > -1
#       require("./apps/#{file}/#{file_sub}")(app)
#   else
#     require("./apps/#{file}")(app)

server.listen config.port, ->
  console.log "Listening on port: #{config.port}"
