import gulp from 'gulp'

import preCommit from '#build/gulp/pre-commit'
import postCommit from '#build/gulp/post-commit'

gulp
  .task('pre-commit', preCommit)

gulp
  .task('post-commit', postCommit)

gulp
  .task('default', gulp.series('pre-commit'))
