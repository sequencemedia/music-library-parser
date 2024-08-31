import {
  resolve,
  join
} from 'node:path'

import {
  rimraf
} from 'rimraf'

export function clear (destination = './Music Library') {
  return (
    rimraf( // ).sync(
      join(
        resolve(destination),
        '*'
      )
    )
  )
}

export * as library from '#music-library-parser/library'
