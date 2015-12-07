router = express.Router()
User = mongoose.model 'User'

router.get '/login', (req, res) ->
  User.find {}, (err, users)->
    flash = req.flash()
    if _.isEmpty flash
      res.render 'login', {users: users}
    else
      res.render 'login', {users: users, message: flash.error[0] }

router.post '/login', passport.authenticate('local',{successRedirect: '/', failureRedirect: '/login', failureFlash: true})

router.get '/', (req, res) ->
  username = undefined
  if !_.isEmpty req.session.passport
    username = req.session.passport.user.username
  res.render 'index', {username: username}

# router.get '/',(req, res) ->
#   if _.isEmpty req.session.passport
#     res.send '<a href="/login">login</a>'
#   else
#     prev_url = req.session.prev_url
#     if prev_url
#       delete req.session.prev_url
#       res.redirect prev_url
#     else
#       res.json req.session

#dev zone
router.get '/check', (req, res)->
  console.log req.session
  res.json req.session

router.get '/remove', (req, res)->
  #TODO: remove data from db
  res.json 'success'
  
router.get '/create/:role/:name', (req, res)->
  user = new User(username: req.params.name, password: 'password', role: req.params.role)
  user.save()
  res.json user
  
router.get '/create_all_user', (req, res)->
  teachers = ['AjThanisa', 'AjManop', 'AjSrinual', 'AjAnuntapat']
  students = ['Book', 'Mamieo']
  for student in students
    user = new User(username: student, password: 'password', role: 'student')
    user.save()
  for teacher in teachers
    user = new User(username: teacher, password: 'password', role: 'teacher')
    user.save()
  res.send 'ok'
#end dev zone


router.get '/logout', (req, res)->
  req.logout()
  res.redirect '/'

module.exports = router