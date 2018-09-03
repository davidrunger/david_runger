module.exports = {
  presets: [
    ['@babel/preset-env', {
      modules: false,
      targets: {
        browsers: '> 1%',
        uglify: true
      },
      useBuiltIns: 'entry'
    }]
  ],

  plugins: [
    '@babel/syntax-dynamic-import',
    '@babel/proposal-object-rest-spread',
    ['@babel/proposal-class-properties', { spec: true }],
    'transform-vue-jsx',
  ],

  env: {
    test: {
      presets: [
        ['env', {
          modules: false,
          targets: { node: 'current' }
        }]
      ]
    },
  }
};
