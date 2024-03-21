module.exports = {
  presets: [
    ['@babel/preset-env', {
      modules: false,
      targets: {
        browsers: '> 1%',
      },
      forceAllTransforms: (process.env.NODE_ENV === 'production'),
    }]
  ],

  plugins: [
    'lodash',
    '@babel/syntax-dynamic-import',
    '@babel/proposal-object-rest-spread',
  ],
};
