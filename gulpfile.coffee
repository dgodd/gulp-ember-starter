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
inflection = require "inflection"
rimraf = require "gulp-rimraf"
stylus = require "gulp-stylus"
watch = require "gulp-watch"
# gulp-uglify
register = require "./support/lib/register"

#
# Configuration TODO move to config.json
#

assetsPattern = "app/assets/**"
modulesSrc = "app/**/*.coffee"
modulesDst = "build/scripts/modules"
stylesPattern = "app/**/*.styl"
templatesSrc = "app/templates/**/*.hbs"
templatesDst = "build/scripts/modules/templates"
vendorPattern = "vendor/**"


#
# Functions
#

moduleRename = (name) ->
  name = name.slice 0, -7 # Remove ".coffee"

moduleContents = (type) ->
  (names) ->
    vars = names.slice()
    vars = vars.map (name) ->
      name = name.slice(2) # Remove ./
      name
    vars.push "app"

    requirements = names.slice()
    requirements.push "app"
    contents = "define(#{JSON.stringify(requirements)}, function ("
    contents += vars.join(",")
    contents += "){"

    names.forEach (name, i) ->
      contents += "app.register('"
      contents += type + ":"
      name = name.slice(2, -(type.length + 1)) # Remove ./ and _type
      contents += inflection.camelize name, true
      contents += "',"
      contents += vars[i]
      contents += ");"
    contents += "});"
    contents

registerModule = (plural) ->
  gulp.src("app/#{plural}/*.coffee", read: false)
  .pipe(register plural, "registry.js", moduleRename, moduleContents(plural.slice(0, -1)), "app/#{plural}")
  .pipe(gulp.dest(modulesDst + "/#{plural}"))

#
# Tasks
#

gulp.task "assets", ->
  gulp.src(assetsPattern).pipe(gulp.dest("build"))

gulp.task "modules", ["register-modules"], ->
  gulp.src(modulesSrc)
  .pipe(coffee(bare: true, sourceMap: true).on("error", gutil.log))
  .pipe(gulp.dest(modulesDst))

gulp.task "register-modules", ->
  registerModule("components")
  registerModule("controllers")
  registerModule("models")
  registerModule("routes")
  registerModule("views")

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

gulp.task "register-templates", ->
  rename = (name) -> name.slice 0, -4 # Remove ".hbs"
  contents = (names) -> "define(#{JSON.stringify(names)}, function () {});"
  gulp.src(templatesSrc)
  .pipe(register "templates", "registry.js", rename, contents)
  .pipe(gulp.dest(templatesDst))

gulp.task "templates", ["register-templates"], ->
  gulp.src(templatesSrc)
  .pipe(handlebars(outputType: "amd"))
  .pipe(gulp.dest(templatesDst))

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
  gulp.watch modulesSrc, ["modules"]
  gulp.watch stylesPattern, ["styles"]
  gulp.watch templatesSrc, ["templates"]
