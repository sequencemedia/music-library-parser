const DATE = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/

function reduceSet (s, o) {
  return s.add(transform(o))
}

function reduceMap (m, [key, value]) {
  switch ((value || false).constructor) {
    case Array:
      return m.set(key, transformArrayToSet(value, new Set()))

    case Object:
      return m.set(key, transformObjectToMap(value, new Map()))
  }

  return m.set(key, DATE.test(value) ? new Date(value) : value)
}

export function transformArrayToSet (a, s) {
  return a.reduce(reduceSet, s)
}

export function transformObjectToMap (o, m) {
  return Object.entries(o).reduce(reduceMap, m)
}

export function transform (v) {
  return Array.isArray(v)
    ? transformArrayToSet(v, new Set())
    : transformObjectToMap(v, new Map())
}
