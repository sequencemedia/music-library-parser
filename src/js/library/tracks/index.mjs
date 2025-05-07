import {
  exec
} from 'node:child_process'

import {
  dirname,
  resolve,
  join
} from 'node:path'

import {
  fileURLToPath
} from 'node:url'

import debug from 'debug'

import {
  clear
} from '#music-library-parser'

const log = debug('@sequencemedia/music-library-parser:to-m3u')
const error = debug('@sequencemedia/music-library-parser:to-m3u:error')

const cwd = resolve(dirname(fileURLToPath(import.meta.url)), '../../../..')
const xsl = join(cwd, 'src/xsl/library/tracks.xsl')

let immediate = null
const queue = []

export function parse (jar, xml, destination = './Music Library') {
  const j = resolve(jar)
  const x = resolve(xml)
  const d = resolve(destination)

  return (
    new Promise((resolve, reject) => {
      exec(`java -jar "${j}" -s:"${x}" -xsl:"${xsl}" destination="${d}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
    })
  )
}

export async function toM3U (jar, xml, destination) {
  /**
   *  Ignore these values if they are duplicates of some in the queue
   */
  if (!queue.some(({ jar: j, xml: x, destination: d }) => (
    j === jar &&
    x === xml &&
    d === destination
  ))) {
    /**
     *  These values are unique, so
     */
    if (immediate) {
      /**
       *  XML is being parsed. En-queue these values
       */
      queue.push({ jar, xml, destination })
      /**
       *  (... if the XML changes while it's being parsed
       *  it should be parsed again immediately after,
       *  so the second of two identical calls will be
       *  put into the queue while the first is executing
       *
       *  In other words: the first call isn't put into the
       *  queue in order to allow that second call to be
       *  put into the queue!)
       */
    } else {
      /**
       *  XML is not being parsed
       */
      immediate = setImmediate(async () => {
        try {
          /**
           *  Clear the destination directory
           */
          await clear(destination)

          log(`Parsing "${xml}" ...`)

          /**
           *  Parse these values immediately
           */
          await parse(jar, xml, destination)

          log(`Succeeded parsing "${xml}"`)

          immediate = null

          if (queue.length) {
            /**
             *  The queue is not empty. De-queue some values
             */

            const {
              jar: j,
              xml: x,
              destination: d
            } = queue.shift()

            /**
             *  Repeat
             */
            return toM3U(j, x, d)
          }

          /**
           *  Return handle from `setImmediate` or null
           */
          return immediate
        } catch (e) {
          const {
            code = 'No error code defined'
          } = e

          if (code === 2) {
            error('I/O error in Saxon', e)
          } else {
            const {
              message = 'No error message defined'
            } = e

            error(code, message, e)
          }
        }
      })
    }
  }
}

export * as transform from '#music-library-parser/library/tracks/transform'
