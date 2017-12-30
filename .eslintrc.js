const { env } = require('process');

module.exports = {
  env: {
    browser: true,
  },
  extends: 'airbnb-base',
  globals: {
    expect: false,
    _: false,
    Routes: false,
  },
  overrides: [
    {
      files: ['spec/javascript/**/*.js'],
      env: {
        mocha: true,
      },
    },
  ],
  plugins: ['vue'],
  rules: {
    'arrow-parens': 'off',
    'dot-location': ['error', 'object'],
    'function-paren-newline': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/prefer-default-export': 'off',
    'max-len': ['warn', 100],
    'newline-per-chained-call': 'off',
    'no-debugger': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-else-return': 'off',
    'no-multiple-empty-lines': ['error', { max: 1 }],
    'no-new': 'off',
    'no-param-reassign': 'off',
    'no-underscore-dangle': 'off',
    'no-use-before-define': ['error', { functions: false }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'object-curly-newline': ['error', {
      consistent: true,
      minProperties: 99,
    }],
  },
  settings: {
    'import/resolver': {
      webpack: {
        config: (
          (env.NODE_ENV === 'production') ?
            'webpack.config.js' :
            'webpack.config.static.js'
        ),
      },
    },
  },
};
