import {
  resolve,
  join
} from 'node:path'
import rimraf from 'rimraf'

export const clear = (destination = './Music Library') => (
  rimraf.sync(join(resolve(destination), '*'))
)

export * as library from '#music-library-parser/library'
