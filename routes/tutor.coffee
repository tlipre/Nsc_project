exec = require("child_process").exec
fs = require 'fs'
express = require 'express'
router = express.Router()

router.get '/compiler', (req, res) ->
  res.render 'text'

router.post '/compiler', (req, res) ->
  command = req.body.command
  # command = "for i in [0..11]\n  console.log i"
  fs.writeFile 'uploads/random1.coffee', command, (err)->
    return res.send err if err  
    ls = exec 'coffee uploads/random1.coffee', (err, stdout, stderr)->
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