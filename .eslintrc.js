const { env } = require('process');

module.exports = {
  env: {
    browser: true,
  },
  extends: 'airbnb-base',
  globals: {
    expect: false,
    _: false,
  },
  plugins: ['vue'],
  rules: {
    'arrow-parens': 'off',
    'function-paren-newline': 'off',
    'no-debugger': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-else-return': 'off',
    'no-new': 'off',
    'no-param-reassign': 'off',
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
        config: 'webpack.config.dev.static.js',
      },
    },
  },
};
