#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

gulp = require "gulp"
path = require "path"
through2 = require("through2")


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


#
# Configuration TODO move to config.json
#

assetsPattern = "app/assets/**"
modulesPattern = "app/**/*.coffee"
stylesPattern = "app/**/*.styl"
templatesSrc = "app/templates/**/*.hbs"
templatesDest = "dist/scripts/modules/templates"
vendorPattern = "vendor/**"


#
# Create registry.js files using a gulp plugin (register).
#

afterDir = (p, dir) ->
  ps = p.split path.sep
  i = ps.lastIndexOf(dir) + 1
  ps.slice(i).join('/')

register = (moduleRoot, nameFn, contentsFn) ->
  nameFn = nameFn || (name) -> name
  contentsFn = contentsFn || (names) -> JSON.stringify(names)
  base = null
  cwd = null
  paths = []

  transform = (file, encoding, callback) ->
    base = file.base if base is null
    cwd = file.cwd if cwd is null
    paths.push file.path
    callback()

  flush = (callback) ->
    names = paths.map (p) ->
      extname = path.extname(p)
      p.slice 0, -extname.length
      "./" + nameFn(afterDir p, moduleRoot)

    contents = contentsFn(names)

    file = new gutil.File
      base: base
      cwd: cwd
      path: path.join base, "registry.js"
      contents: new Buffer(contents)

    this.push file
    this.push null
    callback()

  through2.obj(transform, flush)


#
# Tasks
#

gulp.task "assets", ->
  gulp.src(assetsPattern)
    .pipe(gulp.dest("dist"))

gulp.task "modules", ->
  gulp.src([modulesPattern])
    .pipe(coffee(bare: true).on("error", gutil.log))
    # .pipe(concat("scripts.js"))
    .pipe(gulp.dest("dist/scripts/modules"))

gulp.task "register", ->
  removeHBS = (name) -> name.slice 0, -4 # Remove ".hbs"
  contents = (names) -> "define(".concat JSON.stringify(names), ", function() {});"
  gulp.src(templatesSrc)
  .pipe(register "templates", removeHBS, contents)
  .pipe(gulp.dest(templatesDest))

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
  gulp.src(templatesSrc)
    .pipe(handlebars(outputType: "amd"))
    .pipe(gulp.dest(templatesDest))

gulp.task "vendor", ->
  gulp.src(vendorPattern)
    .pipe(gulp.dest("dist"))

gulp.task "clean", ->
  gulp.src("dist")
    .pipe(rimraf())


#
# The default task boots the development enviroment.
#

gulp.task "default", ["assets", "modules", "register", "styles", "templates", "vendor", "server"], ->
  gulp.watch assetsPattern, ["assets"]
  gulp.watch modulesPattern, ["modules"]
  gulp.watch stylesPattern, ["styles"]
  gulp.watch templatesSrc, ["register", "templates"]
