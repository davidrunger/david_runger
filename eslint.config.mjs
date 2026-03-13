import js from '@eslint/js';
import {
  defineConfigWithVueTs,
  vueTsConfigs,
} from '@vue/eslint-config-typescript';
import eslintConfigPrettier from 'eslint-config-prettier';
import importX from 'eslint-plugin-import-x';
import pluginVue from 'eslint-plugin-vue';
import globals from 'globals';
import { configs as tseslintConfigs } from 'typescript-eslint';
import parser from 'vue-eslint-parser';

export default defineConfigWithVueTs(
  js.configs.recommended,
  tseslintConfigs.strict,
  importX.flatConfigs.recommended,
  importX.flatConfigs.typescript,
  pluginVue.configs['flat/recommended'],
  vueTsConfigs.recommendedTypeChecked,
  eslintConfigPrettier,
  {
    files: ['**/*.js', '**/*.ts', '**/*.vue'],
  },
  {
    ignores: [
      'app/javascript/rails_assets/*',
      'app/javascript/types/bootstrap/*',
      'app/javascript/types/responses/*',
      'app/javascript/types/serializers/*',
      'blog/*',
      'node_modules/*',
      'public/vite-admin/*',
      'public/vite/*',
      'tmp/*',
    ],
  },
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        Routes: false,
      },

      parser,
      ecmaVersion: 'latest',
      sourceType: 'module',

      parserOptions: {
        parser: '@typescript-eslint/parser',
      },
    },

    rules: {
      '@typescript-eslint/no-empty-function': 'off',
      '@typescript-eslint/no-floating-promises': 'off',
      '@typescript-eslint/no-unused-vars': 'off',
      'arrow-parens': 'off',
      'function-paren-newline': 'off',
      'import-x/extensions': [
        'error',
        'ignorePackages',
        {
          js: 'never',
          ts: 'never',
        },
      ],
      'import-x/no-extraneous-dependencies': 'off',
      'import-x/no-named-as-default': 'off',
      'import-x/no-named-as-default-member': 'off',
      'import-x/no-unresolved': [
        'error',
        {
          ignore: ['chartjs-adapter-luxon', 'vue-chartjs'],
        },
      ],
      'import-x/prefer-default-export': 'off',
      'newline-per-chained-call': 'off',
      'no-alert': 'off',
      'no-console': 'warn',
      'no-debugger': 'warn',
      'no-else-return': 'off',
      'no-new': 'off',
      'no-param-reassign': 'off',
      'no-plusplus': 'off',
      'no-restricted-syntax': [
        'error',
        'ForInStatement',
        'LabeledStatement',
        'WithStatement',
      ],
      'no-underscore-dangle': 'off',
      'no-unreachable': 'warn',
      'no-use-before-define': [
        'error',
        {
          functions: false,
        },
      ],
      'no-unused-vars': 'off',
      'object-shorthand': ['error', 'always'],
      'operator-linebreak': 'off',
      'require-await': 'error',
      'vue/block-order': [
        'error',
        {
          order: ['template', 'script', 'style'],
        },
      ],
      'vue/multi-word-component-names': 'off',
    },
  },
);
