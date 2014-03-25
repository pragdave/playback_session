gulp = require('gulp');
gutil  = require('gulp-util');
coffee = require('gulp-coffee');

gulp.task("watch", function() {
    gulp.run("coffee");
    gulp.watch('src/**/*.coffee', function () {
        gulp.run("coffee");
    });
    gulp.watch('test/**/*.coffee', function () {
        gulp.run('test-coffee');
    });
});

gulp.task('coffee', function () {
  gulp.src('./src/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./js/'));
});

gulp.task('test-coffee', function () {
  gulp.src('./test/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./test/js/'))
});
    

