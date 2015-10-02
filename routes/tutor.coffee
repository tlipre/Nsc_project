#THIS FILE IS FOR TESTING ONLY

exec = require("child_process").exec
fs = require 'fs'
router = express.Router()

router.get '/compile', (req, res) ->
  res.render 'text'

router.post '/compile', (req, res) ->
  command = req.body.command
  # command = "for i in [0..11]\n  console.log i"
  fs.writeFile 'public/uploads/random1.py', command, (err)->
    return res.send err if err  
    ls = exec 'python public/uploads/random1.py', (err, stdout, stderr)->
      output = ""
      if !err?
        console.log 'case normal'
        output = stdout
      else
        console.log 'case err'
        output = stderr
        outputAfter = stderr.substr 0, stderr.indexOf '\n'
      res.json {'output':output, 'outputAfter':outputAfter}

module.exports = router