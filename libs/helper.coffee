module.exports = 
  check_role: (req, res, next)->
    if _.isEmpty req.session.passport
      #login first
      req.flash 'error', 'Please login as a teacher to access this'
      res.redirect '/login'
    else
      if req.session.passport.user.role is 'student'
        #logged in as a student
        req.flash 'error', 'Please login as a teacher to access this'
        res.redirect '/login'
      else
        #logged in as a teacher
        next()
  check_auth: (req, res, next)->
    if _.isEmpty req.session.passport
      req.flash 'error', 'You need to login first'
      res.redirect '/login'
    else
      next()
