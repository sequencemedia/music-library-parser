# @sequencemedia/itunes-library-parser

JavaScript functions and XSL stylesheets to parse an Apple Music `Library.xml` file and transform it to [`m3u`](https://en.wikipedia.org/wiki/M3U) files, JSON, or JavaScript.

Requires [Java](https://www.oracle.com/java/technologies/javase-downloads.html) and [Saxon PE](https://www.saxonica.com/welcome/welcome.xml).

## Library

Transforms the entire library.

```javascript
import { toM3U } from './src/js/library/index.mjs'
import {
  toJSON,
  toJS,
  toES
 } from './src/js/library/transform/index.mjs'
```

### `toM3U`

Requires the arguments `jar`, `xml`, and `destination`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the Apple Music `Library.xml` file
- `destination` - the path for the `m3u` files to be written

Returns a `Promise` resolving when all `m3u` files are written.

### `toJSON`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the Apple Music `Library.xml` file

Returns a `Promise` resolving to a `JSON` string.

### `toJS`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the Apple Music `Library.xml` file

Returns a `Promise` resolving to a JavaScript object.

### `toES`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the Apple Music `Library.xml` file

Returns a `Promise` resolving to a collection of JavaScript `Map` and `Set` instances.

## Playlists

Transforms the playlists.

```javascript
import { toM3U } from './src/js/library/playlists/index.mjs'
import {
  toJSON,
  toJS,
  toES
 } from './src/js/library/playlists/transform/index.mjs'
```

See **Library**.

## Tracks

Transforms the tracks.

```javascript
import { toM3U } from './src/js/library/tracks/index.mjs'
import {
  toJSON,
  toJS,
  toES
 } from './src/js/library/tracks/transform/index.mjs'
```

See **Library**.
