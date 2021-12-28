import debug from 'debug'

import {
  exec
} from 'child_process'

const log = debug('@sequencemedia/music-library-parser:build:gulp:pre-commit')

log('`@sequencemedia/music-library-parser` is awake')

const PACKAGE_VERSION_CHANGES = /\-+\s+"version":\s+"(\d+\.\d+\.\d+)",+\s+\++\s+"version":\s+"(\d+\.\d+\.\d+)",+\s+/ /* eslint-disable-line no-useless-escape */

const HAS_STAGED_CHANGES = /Changes to be committed/s

const NOT_STAGED_CHANGES = /Changes not staged for commit/s

const OPTIONS = {
  maxBuffer: 1024 * 500
}

export function hasPackageVersionChanges () {
  log('hasPackageVersionChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git diff HEAD origin/main package.json', OPTIONS, (e, v) => (!e) ? resolve(PACKAGE_VERSION_CHANGES.test(v)) : reject(e))
    })
  )
}

export function notPackageVersionChanges () {
  log('notPackageVersionChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git diff HEAD origin/main package.json', OPTIONS, (e, v) => (!e) ? resolve(PACKAGE_VERSION_CHANGES.test(v) !== true) : reject(e))
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

export function notPushedChanges () {
  log('notPushedChanges')

  return (
    new Promise((resolve, reject) => {
      exec('git log origin/main..HEAD', OPTIONS, (e, v) => (!e) ? resolve(!!v) : reject(e))
    })
  )
}

export function patchPackageVersion () {
  log('patchPackageVersion')

  return (
    new Promise((resolve, reject) => {
      exec('npm version patch -m %s -n --no-git-tag-version --no-verify', OPTIONS, (e) => (!e) ? resolve() : reject(e))
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

export default async function preCommit () {
  log('pre-commit')

  try {
    /**
     *  Not changes added, exit
     */
    if (await notStagedChanges()) return
    /**
     *  Has changes added, continue
     */
    if (await hasStagedChanges()) {
      /**
       *  Not package version changes, continue
       */
      if (await notPackageVersionChanges()) {
        await patchPackageVersion()
        await addPackageVersionChanges()
      }
    }
  } catch ({ code = 'NONE', message = 'No error message defined' }) {
    log({ code, message })
  }
}
