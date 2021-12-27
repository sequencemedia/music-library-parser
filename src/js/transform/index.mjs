export const transformObjectToMap = (o, m) => {
  Object.entries(o)
    .forEach(([key, value] = []) => {
      switch ((value || false).constructor) {
        case Object:
          m.set(key, transformObjectToMap(value, new Map()))
          break

        case Array:
          m.set(key, transformArrayToSet(value, new Set()))
          break

        default:
          m.set(key, /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/.test(value) ? new Date(value) : value)
          break
      }
    })
  return m
}

export const transformArrayToSet = (a, s) => {
  a.forEach((o) => {
    s.add(transform(o))
  })
  return s
}

export const transform = (v) => Array.isArray(v) ? transformArrayToSet(v, new Set()) : transformObjectToMap(v, new Map())
