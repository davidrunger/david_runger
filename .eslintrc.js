const { env } = require('process');

module.exports = {
  env: {
    browser: true,
  },
  extends: [
    'airbnb-base',
    'plugin:vue/essential',
    'eslint:recommended',
  ],
  globals: {
    Routes: false,
  },
  plugins: ['vue'],
  rules: {
    'arrow-parens': 'off',
    'comma-dangle': ['warn', 'always-multiline'],
    'dot-location': ['error', 'object'],
    'function-paren-newline': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/prefer-default-export': 'off',
    'max-len': ['warn', { code: 100, ignoreUrls: true }],
    'newline-per-chained-call': 'off',
    'no-alert': 'off',
    'no-console': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-debugger': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-else-return': 'off',
    'no-multiple-empty-lines': ['error', { max: 1 }],
    'no-new': 'off',
    'no-param-reassign': 'off',
    'no-plusplus': 'off',
    'no-underscore-dangle': 'off',
    'no-unreachable': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-use-before-define': ['error', { functions: false }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'object-curly-newline': ['error', {
      consistent: true,
      minProperties: 99,
    }],
    'operator-linebreak': 'off',
    'quotes': ['warn', 'single', { avoidEscape: true }],
    'semi': ['warn', 'always'],
    'space-before-function-paren': ['warn', {
      anonymous: 'always',
      named: 'never',
      asyncArrow: 'always',
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
    react: {
      version: '16.4.2',
    },
  },
};
