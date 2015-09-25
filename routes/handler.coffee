router = express.Router()

router.use (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err

if app.get('env') == 'development'
  router.use (err, req, res, next )->
    res.status err.status || 500
    res.render 'error',
      message: err.message
      error: err
else
  router.use (err, req, res, next) ->
    res.status err.status || 500
    res.render 'error',
      message: err.message
      error: {}

module.exports = router