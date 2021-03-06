config =
  development:
    container_id: "6c57d3d50745"
    mongodb: "mongodb://localhost/senior_project"
    port: 3000
    bundle_up:
      bundle: true
      minify_css: false
      minify_js: false
    have_docker: true
  production:
    container_id: "6c57d3d50745"
    mongodb: "mongodb://localhost/senior_project"
    port: 3001
    bundle_up:
      bundle: true
      minify_css: true
      minify_js: true
    have_docker: true

module.exports = config