passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = mongoose.model 'User'

passport.use new LocalStrategy (username, password, done) ->
  User.findOne {'username': username, 'password': password}, (err, user)->
    if err
      console.log 'Database error from query user'.red
      done "Can't connect to database."
    if user
      done null, user
    else
      console.log 'wrong username or password'.red
      done null, false, {message: 'Incorrect username or password.'}

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)
  
module.exports = passport