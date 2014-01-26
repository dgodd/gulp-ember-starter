#
# Copyright (c) 2014 Fuse Elements, LLC. All rights reserved.
#

gulp = require "gulp"
gutil = require "gulp-util"
coffee = require "gulp-coffee"

gulp.task "default", ->
  gulp.src(["./src/**/*.coffee"])
  .pipe(coffee(bare: true).on("error", gutil.log))
  .pipe(gulp.dest("./lib"))
