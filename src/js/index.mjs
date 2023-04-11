import {
  resolve
} from 'node:path'
import {
  rimraf
} from 'rimraf'

export function clear (destination = './Music Library') {
  const d = resolve(destination)

  return (
    new Promise((resolve, reject) => {
      rimraf(`${d}/*`, (e) => (!e) ? resolve() : reject(e))
    })
  )
}

export * as library from '#music-library-parser/library'
