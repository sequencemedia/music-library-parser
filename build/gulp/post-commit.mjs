import debug from 'debug'

import {
  readFile
} from 'fs/promises'

import {
  exec
} from 'child_process'

const OPTIONS = {
  maxBuffer: 1024 * 500
}

const log = debug('@sequencemedia/music-library-parser:build:gulp:post-commit')
const error = debug('@sequencemedia/music-library-parser:build:gulp:post-commit:error')

log('`@sequencemedia/music-library-parser` is awake')

export async function getPackageVersion () {
  log('getPackageVersion')

  const {
    version = '0.0.0'
  } = JSON.parse(await readFile('./package.json', 'utf8'))

  return version
}

export function gitTag (a = '0.0.0', m = `v${a}`) {
  log('gitTag')

  return (
    new Promise((resolve, reject) => {
      exec(`git tag -a v${a} -m "${m}"`, OPTIONS, (e, v) => (!e) ? resolve(v) : reject(e))
    })
  )
}

export default async function postCommit () {
  log('post-commit')

  try {
    await gitTag(await getPackageVersion())
  } catch ({ code = 'NONE', message = 'No error message defined' }) {
    error({ code, message })
  }
}
