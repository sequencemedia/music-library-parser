# Rust transformation options

These notes record suggestions for replacing the Java/Saxon dependency used to
transform an Apple Music `Library.xml` export. They describe possible approaches;
no Rust implementation has been added.

## Existing transformations

The stylesheets currently handle three main tasks:

- [JSON conversion](../src/xsl/to-json.xsl): convert plist dictionaries, arrays,
  integers, booleans, strings, dates, and data to JSON. The entry stylesheets
  select the entire library, tracks, or playlists.
- [Album exports](../src/xsl/library/tracks.xsl): filter audio tracks, group by
  album artist or artist and album, handle compilations separately, sort by disc
  and track number, and write M3U8 files.
- [Playlist exports](../src/xsl/library/playlists.xsl): filter playlists, resolve
  parent folders and track IDs, handle duplicate names, and write M3U8 files.

The JavaScript wrappers also expose parsed JavaScript objects and convert those
objects to `Map`, `Set`, and `Date` instances.

## Approaches

There are two broad directions: express the transformation rules in Rust, or
retain XSL stylesheets and use a Rust XSLT engine. Writing transformation rules in
Rust does not require writing a custom XML parser.

| Approach | Benefits | Tradeoffs |
| --- | --- | --- |
| `plist` with Rust transformation code | Parses Apple's format directly; supports dynamic values and typed deserialization. Recommended starting point. | Filtering, grouping, sorting, naming, and output rules need to be translated into Rust. A complete value tree retains the library in memory. |
| `quick-xml` with custom plist parsing and transformation code | Gives control over incremental parsing and which metadata is retained. | Requires handling plist key/value pairing and types explicitly, as well as implementing the transformation rules. |
| `xrust` with adapted XSL stylesheets | Retains the stylesheet approach. | Requires a compatibility investigation; Java extension calls need replacing, and the required XSLT features must be verified. |

## Suggested crates

### `plist`

[`plist`](https://docs.rs/plist/latest/plist/) is the first choice for reading
`Library.xml`. It understands the alternating `<key>` and value elements in Apple
property lists, including dictionaries, arrays, dates, and binary data.

Use `plist::Value` when arbitrary library fields should be retained, or Serde
deserialization into Rust structs when a defined subset of fields is sufficient.

### `serde` and `serde_json`

[`serde`](https://serde.rs/) and
[`serde_json`](https://docs.rs/serde_json/latest/serde_json/index.html) provide the
JSON output layer. They support typed structures and dynamic JSON values, and
replace the handwritten JSON escaping in the current stylesheets. JSON can be
written to a string or directly to a writer.

Define the mapping from plist types to JSON explicitly, particularly for dates
and binary data, rather than assuming default serialization matches the XSL.

### `unicode-normalization`

[`unicode-normalization`](https://docs.rs/unicode-normalization/latest/unicode_normalization/trait.UnicodeNormalization.html)
provides `.nfd()`, corresponding to the canonical decomposition used by
`seq:normalize-for-path`. Apply the existing character removal, replacement, and
whitespace rules after decomposition.

### `percent-encoding` or `url`

[`percent-encoding`](https://docs.rs/percent-encoding/latest/percent_encoding/)
fits the percent-decoding currently performed through Java's `URLDecoder`.
Percent decoding preserves literal `+` characters, matching the intent of the
stylesheet's workaround for form-style decoding.

[`url`](https://docs.rs/url/latest/url/struct.Url.html#method.to_file_path) is an
alternative when explicit URL parsing and conversion from `file:` URLs to native
paths are desired. Check its behavior against the existing decode-and-strip
rules before adopting it as a replacement.

### `quick-xml`

[`quick-xml`](https://docs.rs/quick-xml/latest/quick_xml/) is an alternative to
`plist` when large libraries justify incremental XML parsing. Its pull reader
allows processing records while retaining only the information needed later.

Album grouping and playlist track lookups still require retained state, so
streaming XML does not eliminate all memory use. Prefer this approach when
library size or measured memory use warrants the additional parsing code.

## M3U8 output

The current output only needs `#EXTM3U`, `#EXTINF` duration/title entries, and
track paths. `std::io::Write` and `BufWriter` should be sufficient initially.

[`m3u8-rs`](https://docs.rs/m3u8-rs/latest/m3u8_rs/) focuses on HTTP Live Streaming
playlists, so it is not the first choice for these local music playlists.

## Retaining XSL with `xrust`

[`xrust`](https://docs.rs/xrust/latest/xrust/) is worth investigating if retaining
the stylesheets is a priority. Its documented XSLT implementation is incomplete;
treat it as a compatibility experiment rather than an established replacement
for Saxon.

The existing stylesheets use grouping, custom functions, multiple result
documents, imports, and Java extension calls. Verify support for each required
feature. Calls to `java.net.URLDecoder` would need replacement.

## Compatibility details

Before implementing a replacement, decide which existing behaviors must be
preserved:

- **Binary data:** the JSON stylesheet emits `<data>` as an array of base64 text
  lines. `plist::Value::Data` contains decoded bytes and does not retain the
  original base64 line wrapping. Exact compatibility requires deliberate handling.
- **Dates:** the JSON stylesheet preserves date text as strings. The JavaScript
  `toES` conversion subsequently creates `Date` instances from matching strings.
- **Path normalization:** the stylesheets remove U+0300–U+036F after NFD
  decomposition. Removing all Unicode combining marks would change the behavior.
  Playlist and album filename rules also differ over double quotes.
- **Ordering:** retain playlist item order and duplicates, and reproduce album
  sorting by disc and track number. A Rust set should not replace a playlist's
  ordered list of track references.
- **Track locations:** preserve literal plus signs and check percent decoding,
  `file:` URL handling, and non-file locations.
- **M3U8 formatting:** the stylesheets emit carriage-return-only line endings.
  Durations are floored from milliseconds to seconds; zero and missing values
  produce `-1`.
- **Selection and naming:** preserve the album and playlist filters, compilation
  handling, parent folder resolution, and duplicate-name suffix rules where
  compatibility is required.

The recommended starting point is `plist`, `serde`, `serde_json`,
`unicode-normalization`, and `percent-encoding`, with ordinary Rust collections
for grouping and lookups and standard buffered I/O for M3U8 output.
