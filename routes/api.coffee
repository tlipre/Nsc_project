router = express.Router()

router.get '/kebab-case/:word',(req,res) ->
  word = req.params.word
  res.send _.kebabCase(word)

module.exports = router