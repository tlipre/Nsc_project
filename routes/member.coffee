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
    prev_url = req.session.prev_url
    if prev_url
      delete req.session.prev_url
      res.redirect prev_url
    else
      res.redirect '/debug'

router.get '/check', (req, res)->
  res.send 'ok'

router.get '/create/:role', (req, res)->
  user = new User(username: 'Mamieo', password: 'password', role: req.params.role)
  user.save()
  res.json user

router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router