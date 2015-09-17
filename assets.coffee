module.exports = (assets) ->
  assets.root = __dirname
  
  # assets.addJs '/public/javascripts/jquery-1.11.1.js'
  assets.addJs '/assets/javascripts/state.coffee'
  assets.addCss '/assets/stylesheets/test.styl'