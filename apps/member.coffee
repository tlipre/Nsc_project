module.exports = (app) -> 
  app.get '/login',(req,res) ->
    res.render 'test'

  app.post '/login', passport.authenticate 'local',{successRedirect: '/',failureRedirect: '/login'}
  
  app.get '/',(req,res) ->
    console.log req.session
    console.log res.locals.session
    if current_user?
      res.send current_user
    else
      res.send '<a href="/login">login</a>'