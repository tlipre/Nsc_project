router = express.Router()

router.get '/',(req,res) ->
  res.render 'e_classroom_teacher'

module.exports = router