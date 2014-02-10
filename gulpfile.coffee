#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

gulp = require "gulp"

#
# Plugins
#

coffee = require "gulp-coffee"
concat = require "gulp-concat"
gutil = require "gulp-util"
handlebars = require "gulp-ember-handlebars"
rimraf = require "gulp-rimraf"
stylus = require "gulp-stylus"
watch = require "gulp-watch"
# gulp-requirejs
# gulp-uglify
register = require "./support/lib/register"

#
# Configuration TODO move to config.json
#

assetsPattern = "app/assets/**"
modulesPattern = "app/**/*.coffee"
stylesPattern = "app/**/*.styl"
templatesSrc = "app/templates/**/*.hbs"
templatesDest = "build/scripts/modules/templates"
vendorPattern = "vendor/**"


#
# Tasks
#
  
gulp.task "assets", ->
  gulp.src(assetsPattern).pipe(gulp.dest("build"))

gulp.task "modules", ->
  gulp.src([modulesPattern])
  .pipe(coffee(bare: true, sourceMap: true).on("error", gutil.log))
  # .pipe(concat("scripts.js"))
  .pipe(gulp.dest("build/scripts/modules"))

gulp.task "register-templates", ->
  rename = (name) -> name.slice 0, -4 # Remove ".hbs"
  contents = (names) -> "define(#{JSON.stringify(names)}, function () {});"
  gulp.src(templatesSrc)
  .pipe(register "templates", "registry.js", rename, contents)
  .pipe(gulp.dest(templatesDest))

gulp.task "server", ->
  connect = require "connect"
  server = connect()
  .use(connect.logger("dev"))
  .use("/scripts/modules", connect.static(__dirname + "/app"))
  .use("/", connect.static(__dirname + "/build"))
  http = require "http"
  http.createServer(server).listen(3333)
  gutil.log "Development server listening on http://localhost:3333."

gulp.task "styles", ->
  gulp.src([stylesPattern])
  .pipe(stylus(use: ["nib"]))
  .pipe(concat("app.css"))
  .pipe(gulp.dest("build/styles"))

gulp.task "templates", ["register-templates"], ->
  gulp.src(templatesSrc)
  .pipe(handlebars(outputType: "amd"))
  .pipe(gulp.dest(templatesDest))

gulp.task "vendor", ->
  gulp.src(vendorPattern).pipe(gulp.dest("build"))

gulp.task "clean", ->
  gulp.src("build", read: false).pipe(rimraf())
  gulp.src("support/lib", read: false).pipe(rimraf())


#
# The default task boots the development enviroment.
#

gulp.task "default", ["assets", "modules", "styles", "templates", "vendor", "server"], ->
  gulp.watch assetsPattern, ["assets"]
  gulp.watch modulesPattern, ["modules"]
  gulp.watch stylesPattern, ["styles"]
  gulp.watch templatesSrc, ["templates"]
