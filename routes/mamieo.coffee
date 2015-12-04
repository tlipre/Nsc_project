router = express.Router()
Docker = require('dockerode');
docker = new Docker({socketPath: '/var/run/docker.sock'});

docker.createContainer {Image: 'ubuntu', Cmd: ['/bin/bash'], name: 'ubuntu-test'}, (err, container) ->
  console.log err

router.get '/',(req,res) ->
  res.render 'e_classroom_teacher'

module.exports = router