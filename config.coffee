config =
  development:
    port: 3000
    bundle_up:
      bundle: true
      minify_css: true
      minify_js: true
  production: 
    port: 3001
    bundle_up:
      bundle: true
      minify_css: true
      minify_js: true

module.exports = config