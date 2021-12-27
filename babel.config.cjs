const presets = [
  [
    '@babel/env',
    {
      targets: {
        node: 'current'
      },
      useBuiltIns: 'usage',
      corejs: 3
    }
  ]
]

const plugins = [
  '@babel/proposal-export-default-from',
  '@babel/proposal-export-namespace-from'
]

module.exports = {
  compact: true,
  comments: false,
  presets,
  plugins
}
