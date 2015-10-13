router = express.Router()
User = mongoose.model 'User'
fs = require 'fs'

router.get '/login', (req, res) ->
  console.log req.flash()
  res.render 'login'

router.post '/login', passport.authenticate('local',{successRedirect: '/', failureRedirect: '/login', failureFlash: true})

router.get '/',(req, res) ->
  if Object.keys(req.session.passport).length != 0
    current_user = req.session.passport.user
  else
    console.log "plz login".red
  if current_user?
    res.send current_user
  else
    res.send '<a href="/login">login</a>'

router.get '/check', (req, res)->
  console.log req.session
  res.send 'ok'
router.get '/create', (req, res)->
  user = new User(username: 'book', password: 'book')
  user.save()
  res.json user

router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router