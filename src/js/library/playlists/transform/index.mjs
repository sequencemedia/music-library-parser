import {
  exec
} from 'child_process'

import path from 'path'

import {
  fileURLToPath
} from 'url'

import {
  readFile
} from 'fs/promises'

import debug from 'debug'

import {
  transform
} from '#music-library-parser/transform'

const error = debug('@sequencemedia/music-library-parser:to-json:error')

const cwd = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../../..')
const xsl = path.resolve(cwd, 'src/xsl/library/tracks/to-json.xsl')
const DESTINATION = path.resolve(cwd, '.music-library/playlists.json')

/**
 *  `maxBuffer`
 */
export function parse (jar, xml, destination = DESTINATION) {
  return (
    new Promise((resolve, reject) => {
      exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" -o:"${destination}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
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
