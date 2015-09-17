passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

passport.use new LocalStrategy (username, password, done) ->
  if username == 'book' && password == 'book'
    user = {'username':'book'}
  else
    user = false
  if !user
    return done null, false, { message: 'Incorrect username or password.' }
  return done null, user

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)
  
module.exports = passport