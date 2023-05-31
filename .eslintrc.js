const { env } = require('process');

module.exports = {
  env: {
    browser: true,
  },
  extends: [
    'plugin:vue/vue3-essential',
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/typescript',
    '@vue/eslint-config-typescript',
  ],
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    sourceType: 'module',
  },
  globals: {
    Routes: false,
  },
  plugins: [
    'import',
    '@typescript-eslint',
    'vue',
  ],
  settings: {
    'import/parsers': {
      '@typescript-eslint/parser': ['.ts'],
    },
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true,
      },
    },
  },
  rules: {
    '@typescript-eslint/no-empty-function': 'off',
    'arrow-parens': 'off',
    'comma-dangle': ['warn', 'always-multiline'],
    'dot-location': ['error', 'object'],
    'function-paren-newline': 'off',
    // https://github.com/import-js/eslint-import-resolver-typescript/issues/39#issuecomment-571489805
    'import/extensions': [
      'error',
      'ignorePackages',
      {
        js: 'never',
        ts: 'never',
      },
    ],
    'import/no-extraneous-dependencies': 'off',
    // https://github.com/import-js/eslint-plugin-import/issues/1810#issuecomment-1142145572
    'import/no-unresolved': ['error', { ignore: ['chartjs-adapter-luxon', 'vue-chartjs'] }],
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
    'no-restricted-imports': ['error', {
      paths: [{
        name: 'lodash',
        message: 'Use lodash-es.',
      }],
    }],
    'no-restricted-syntax': [
      'error',
      'ForInStatement',
      'LabeledStatement',
      'WithStatement',
    ],
    'no-underscore-dangle': 'off',
    'no-unreachable': ((env.NODE_ENV === 'production') ? 'error' : 'warn'),
    'no-use-before-define': ['error', { functions: false }],
    // https://stackoverflow.com/a/64067915/4009384
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
        caughtErrorsIgnorePattern: '^_',
      },
    ],
    'object-curly-newline': ['error', {
      consistent: true,
      minProperties: 99,
    }],
    'operator-linebreak': 'off',
    quotes: ['warn', 'single', { avoidEscape: true }],
    'require-await': 'error',
    semi: ['warn', 'always'],
    'space-before-function-paren': ['warn', {
      anonymous: 'always',
      named: 'never',
      asyncArrow: 'always',
    }],
    'vue/multi-word-component-names': 'off',
  },
};
