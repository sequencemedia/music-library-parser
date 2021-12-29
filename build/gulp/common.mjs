import debug from 'debug'

import {
  exec
} from 'child_process'

import {
  readFile
} from 'fs/promises'

const log = debug('@sequencemedia/music-library-parser:build:gulp:common')

export const PACKAGE_VERSION_CHANGES = /\-+\s+"version":\s+"(\d+\.\d+\.\d+)",+\s+\++\s+"version":\s+"(\d+\.\d+\.\d+)",+\s+/ /* eslint-disable-line no-useless-escape */

export const HAS_STAGED_CHANGES = /Changes to be committed/s

export const NOT_STAGED_CHANGES = /Changes not staged for commit/s

export const OPTIONS = {
  maxBuffer: 1024 * 500
}

export const BRANCH = 'master'

export const trim = (v) => v.split('\n').map((v) => v.trimEnd()).join('\n').trim()

export function use (key) {
  const log = debug(`@sequencemedia/music-library-parser:${key}`)

  return function use (v) {
    log(trim(v))
  }
}

export function getGitRemoteShowOriginHeadBranch () {
  log('getGitRemoteShowOriginHeadBranch')

  return (
    new Promise((resolve, reject) => {
      const command = 'git remote show origin | awk \'/HEAD branch/ {print $NF}\''

      const {
        stdout,
        stderr
      } = exec(command, OPTIONS, (e, v = '') => (!e) ? resolve(trim(v)) : reject(e))

      stdout.on('data', use('git-remote-show-origin-head-branch'))
      stderr.on('data', use('git-remote-show-origin-head-branch'))
    })
  )
}

export function hasPackageVersionChanges (branch = BRANCH) {
  log('hasPackageVersionChanges')

  return (
    new Promise((resolve, reject) => {
      exec(`git diff HEAD origin/${branch} package.json`, OPTIONS, (e, v) => (!e) ? resolve(PACKAGE_VERSION_CHANGES.test(v)) : reject(e))
    })
  )
}

export function notPackageVersionChanges (branch = BRANCH) {
  log('notPackageVersionChanges')

  return (
    new Promise((resolve, reject) => {
      exec(`git diff HEAD origin/${branch} package.json`, OPTIONS, (e, v) => (!e) ? resolve(PACKAGE_VERSION_CHANGES.test(v) !== true) : reject(e))
    })
  )
}

export function addPackageVersionChanges () {
  log('addPackageVersionChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git add package.json package-lock.json', OPTIONS, (e) => (!e) ? resolve() : reject(e))
    })
  )
}

export function hasStagedChanges () {
  log('hasStagedChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git status', OPTIONS, (e, v) => (!e) ? resolve(HAS_STAGED_CHANGES.test(v)) : reject(e))
    })
  )
}

export function notStagedChanges () {
  log('notStagedChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git status', OPTIONS, (e, v) => (!e) ? resolve(NOT_STAGED_CHANGES.test(v)) : reject(e))
    })
  )
}

export function notPushedChanges (branch = BRANCH) {
  log('notPushedChanges')

  return (
    new Promise((resolve, reject) => {
      exec(`git log origin/${branch}..HEAD`, OPTIONS, (e, v) => (!e) ? resolve(!!v) : reject(e))
    })
  )
}

export async function getPackageVersion () {
  log('getPackageVersion')

  const {
    version = '0.0.0'
  } = JSON.parse(await readFile('./package.json', 'utf8'))

  return version
}

export function patchPackageVersion () {
  log('patchPackageVersion')

  return (
    new Promise((resolve, reject) => {
      exec('npm version patch -m %s -n --commit-hooks false --no-verify', OPTIONS, (e) => (!e) ? resolve() : reject(e))
    })
  )
}

export function gitTag (a = '0.0.0', m = `v${a}`) {
  log('gitTag')

  return (
    new Promise((resolve, reject) => {
      exec(`git tag -a v${a} -m "${m}"`, OPTIONS, (e, v) => (!e) ? resolve(v) : reject(e))
    })
  )
}
