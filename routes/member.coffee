router = express.Router()
User = mongoose.model 'User'
fs = require 'fs'

router.get '/login', (req, res) ->
  flash = req.flash()
  if _.isEmpty flash
    res.render 'login'
  else
    res.render 'login', { message: flash.error[0] }

router.post '/login', passport.authenticate('local',{successRedirect: '/', failureRedirect: '/login', failureFlash: true})

router.get '/',(req, res) ->
  if _.isEmpty req.session.passport
    res.send '<a href="/login">login</a>'
  else
    res.json req.session.passport.user

router.get '/check', (req, res)->
  console.log req.session
  res.send 'ok'

router.get '/create/:role', (req, res)->
  user = new User(username: 'AjJoob', password: 'password', role: req.params.role)
  user.save()
  res.json user

router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router