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
stylus = require "gulp-stylus"
transpiler = require "gulp-es6-module-transpiler"
watch = require "gulp-watch"
# gulp-requirejs
# gulp-rimraf
# gulp-uglify


#
# Configuration TODO move to config.json
#
assetsPattern = "app/assets/**"
modulesPattern = "app/**/*.coffee"
stylesPattern = "app/**/*.styl"
templatesPattern = "app/templates/**/*.hbs"
vendorPattern = "vendor/**"


#
# Tasks
#
gulp.task "assets", ->
  gulp.src(assetsPattern)
    .pipe(gulp.dest("dist"))

gulp.task "modules", ->
  gulp.src([modulesPattern])
    .pipe(coffee(bare: true).on("error", gutil.log))
    .pipe(transpiler(type: "amd"))
    # .pipe(concat("scripts.js"))
    .pipe(gulp.dest("dist/scripts/modules"))

gulp.task "server", ->
  connect = require "connect"
  server = connect()
    .use(connect.logger("dev"))
    .use("/", connect.static(__dirname + "/dist"))
  http = require "http"
  http.createServer(server).listen(3333)
  gutil.log "Development server listening on http://localhost:3333."

gulp.task "styles", ->
  gulp.src([stylesPattern])
    .pipe(stylus(use: ["nib"]))
    .pipe(concat("app.css"))
    .pipe(gulp.dest("dist/styles"))

gulp.task "templates", ->
  gulp.src(templatesPattern)
    .pipe(handlebars(outputType: "amd"))
    .pipe(gulp.dest("dist/scripts/modules/templates"))

gulp.task "vendor", ->
  gulp.src(vendorPattern)
    .pipe(gulp.dest("dist"))


#
# The default task boots the development enviroment.
#
gulp.task "default", ->
  gulp.run "assets", "modules", "server", "styles", "templates", "vendor"

  gulp.watch assetsPattern, ->
    gulp.run "assets"

  gulp.watch modulesPattern, ->
    gulp.run "modules"

  gulp.watch stylesPattern, ->
    gulp.run "styles"

  gulp.watch templatesPattern, ->
    gulp.run "templates"
