router = express.Router()
User = mongoose.model 'User'
Container = mongoose.model 'Container'
Chat_log = mongoose.model 'Chat_log'
Classroom = mongoose.model 'Classroom'
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
      res.json req.session

#dev zone
router.get '/check', (req, res)->
  res.json req.session

router.get '/remove', (req, res)->
  #TODO: remove data from db
  res.json 'success'
#end dev zone

router.get '/create/:role', (req, res)->
  user = new User(username: 'Mamieo', password: 'password', role: req.params.role)
  user.save()
  res.json user

router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router