config =
  development:
    port: 3000
    bundle_up:
      bundle: false
      minify_css: false
      minify_js: false
  production: 
    port: 3001
    bundle_up:
      bundle: true
      minify_css: true
      minify_js: false

module.exports = config