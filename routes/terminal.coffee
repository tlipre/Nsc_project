term = require('term.js');
app.use(term.middleware());

ansi = require('ansi-html-stream')
pty = require('pty.js');

term = pty.spawn 'docker', ["run", "-it","8251da35e7a7"], 
  name: 'xterm-color',
  cols: 80,
  rows: 30,
  cwd: process.env.HOME,
  env: process.env

router = express.Router()

router.get '/terminal', (req, res) ->
  res.render 'terminal'

io.on 'connection', (socket)->


  console.log('Have connection')

  term.on 'data', (data) -> 
    socket.emit('data',data)

  socket.on 'data', (command) ->
    #
    term.write command

  socket.on 'disconnect', () ->
    #TODO: destroy
    console.log "Disconect"

module.exports = router