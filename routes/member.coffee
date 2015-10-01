router = express.Router()

router.get '/login',(req,res) ->
  res.render 'login'

router.post '/login', passport.authenticate 'local',{successRedirect: '/',failureRedirect: '/login'}

router.get '/',(req,res) ->
  if Object.keys(req.session.passport).length != 0
    current_user = req.session.passport.user
  else
    console.log "plz login".red
  if current_user?
    res.send current_user
  else
    res.send '<a href="/login">login</a>'

router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router