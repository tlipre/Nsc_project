router = express.Router()

router.get '/ping', (req, res) ->
  now = Math.round (new Date()).getTime() / 1000
  res.json {timestamp: now}

router.get '/debug/session', (req, res) ->
  req.session.count++
  data =
    session: req.session
    ip: req_ip
  res.json data

router.get '/redirect', (req, res) ->
  if req.session.redirectTo?
    path = req.session.redirectTo
  else
    path = "/"
  res.redirect path

module.exports = router