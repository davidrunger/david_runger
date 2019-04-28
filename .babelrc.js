module.exports = {
  presets: [
    ['@babel/preset-env', {
      modules: false,
      targets: {
        browsers: '> 1%',
      },
      forceAllTransforms: (process.env.NODE_ENV === 'production'),
      useBuiltIns: 'entry'
    }]
  ],

  plugins: [
    '@znck/prop-types/remove',
    '@babel/syntax-dynamic-import',
    '@babel/proposal-object-rest-spread',
    ['@babel/proposal-class-properties', { spec: true }],
  ],

  env: {
    test: {
      presets: [
        ['@babel/env', {
          modules: false,
          targets: { node: 'current' }
        }]
      ]
    },
  }
};
