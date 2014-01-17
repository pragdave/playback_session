gulp = require 'gulp'
gutil  = require('gulp-util')
coffee = require('gulp-coffee')

gulp.task "watch", ->
    gulp.run "coffee"
    gulp.watch 'src/**/*.coffee', ->
        gulp.run "coffee"

gulp.task 'coffee', ->
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./js/'))

