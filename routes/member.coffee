express = require 'express'
router = express.Router()

router.get '/login',(req,res) ->
  res.render 'test'

router.post '/login', passport.authenticate 'local',{successRedirect: '/',failureRedirect: '/login'}

router.get '/',(req,res) ->
  console.log req.session
  console.log res.locals.session
  if current_user?
    res.send current_user
  else
    res.send '<a href="/login">login</a>'

module.exports = router