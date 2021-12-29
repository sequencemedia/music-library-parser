import gulp from 'gulp'

import {
  postCommit
} from '@sequencemedia/hooks'

gulp
  .task('post-commit', postCommit)

gulp
  .task('default', gulp.series('post-commit'))
