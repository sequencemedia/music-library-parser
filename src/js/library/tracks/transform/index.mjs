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

import {
  readFile
} from 'node:fs/promises'

import debug from 'debug'

import {
  transform
} from '#music-library-parser/transform'

const error = debug('@sequencemedia/music-library-parser:to-json:error')

const cwd = resolve(dirname(fileURLToPath(import.meta.url)), '../../../../..')
const xsl = join(cwd, 'src/xsl/library/tracks/to-json.xsl')
const DESTINATION = join(cwd, '.music-library/tracks.json')

/**
 *  `maxBuffer`
 */
export function parse (jar, xml, destination = DESTINATION) {
  const j = resolve(jar)
  const x = resolve(xml)

  return (
    new Promise((resolve, reject) => {
      exec(`java -jar "${j}" -s:"${x}" -xsl:"${xsl}" -o:"${destination}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
    })
  )
}

async function execute (jar, xml) {
  await parse(jar, xml, DESTINATION)

  return (
    await readFile(DESTINATION, 'utf8')
  )
}

export async function toJSON (jar, xml) {
  try {
    const fileData = await execute(jar, xml)

    return fileData.toString('utf8')
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to JSON')
  }
}

export async function toJS (jar, xml) {
  try {
    return JSON.parse(await toJSON(jar, xml))
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to JS')
  }
}

export async function toES (jar, xml) {
  try {
    return transform(JSON.parse(await toJSON(jar, xml)))
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to ES')
  }
}

export default {
  toJSON,
  toJS,
  toES
}
