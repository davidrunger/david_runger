module.exports = {
  env: {
    browser: true,
  },
  extends: 'airbnb-base',
  plugins: ['vue'],
  rules: {
    'arrow-parens': 'off',
    'function-paren-newline': 'off',
    'no-else-return': 'off',
    'no-new': 'off',
    'no-param-reassign': 'off',
    'no-use-before-define': ['error', { functions: false }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
};
