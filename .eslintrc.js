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
  plugins: ['vue'],
  rules: {
    'arrow-parens': 'off',
    'function-paren-newline': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/prefer-default-export': 'off',
    'max-len': ['warn', 100],
    'no-debugger': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-else-return': 'off',
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
