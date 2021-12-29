import debug from 'debug'

import {
  getPackageVersion,
  gitTag
} from '#build/gulp/common'

const log = debug('@sequencemedia/music-library-parser:build:gulp:post-commit')
const error = debug('@sequencemedia/music-library-parser:build:gulp:post-commit:error')

log('`@sequencemedia/music-library-parser` is awake')

export default async function postCommit () {
  log('post-commit')

  try {
    await gitTag(await getPackageVersion())
  } catch ({ code = 'NONE', message = 'No error message defined' }) {
    error({ code, message })
  }
}
