import gulp from 'gulp'

import preCommit from '#build/gulp/pre-commit'

gulp
  .task('pre-commit', preCommit)

gulp
  .task('default', gulp.series('pre-commit'))
