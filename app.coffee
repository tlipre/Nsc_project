config = require('./config')[process.env.NODE_ENV || 'development']
global.express = require 'express' 
global.app = express()
global.colors = require 'colors'
path = require 'path'
bundle_up = require 'bundle-up3'
fs = require 'fs'
body_parser = require 'body-parser'
cookie_parser = require 'cookie-parser'
session = require 'express-session'
RedisStore = require('connect-redis')(session)
morgan = require 'morgan'


server = require('http').createServer(app)
global.io = require('socket.io')(server)

global.passport = require './libs/passport'

app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade' 
app.use express.static "#{__dirname}/public"
app.use body_parser.json()
app.use body_parser.urlencoded {extended: true}
app.use morgan 'dev'
app.use cookie_parser()
app.use session
  secret: "bookmamieo"
  store : new RedisStore
    host : 'localhost'
    port : '6379'
    pass : ''
  cookie :
    maxAge : 604800 
  resave: true
  saveUninitialized: true
app.use passport.initialize()
app.use passport.session()

#==================================================#
#bundle_up css and js
bundle_up app, __dirname + '/assets' ,
  staticRoot: __dirname + '/public/'
  staticUrlRoot: '/'
  bundle: true
  minifyCss: true
  minifyJs: true
  

server.listen config.port, ->
  console.log "Listening on port: #{config.port}"
  
app.use require './routes/compiler'
app.use require './routes/member'
app.use require './routes/tutor'
app.use require './routes/util'
app.use require './routes/terminal'

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

