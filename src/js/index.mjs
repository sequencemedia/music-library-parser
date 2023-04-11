import path from 'path'
import {
  rimraf
} from 'rimraf'

export const clear = (destination = './Music Library') => (
  new Promise((resolve, reject) => {
    rimraf(`${path.resolve(destination)}/*`, (e) => (!e) ? resolve() : reject(e))
  })
)

export * as library from '#music-library-parser/library'
