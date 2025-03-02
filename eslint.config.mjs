import js from '@eslint/js';
import {
  defineConfigWithVueTs,
  vueTsConfigs,
} from '@vue/eslint-config-typescript';
import eslintConfigPrettier from 'eslint-config-prettier';
import importPlugin from 'eslint-plugin-import';
import pluginVue from 'eslint-plugin-vue';
import globals from 'globals';
import { configs as tseslintConfigs } from 'typescript-eslint';
import parser from 'vue-eslint-parser';

export default defineConfigWithVueTs(
  js.configs.recommended,
  tseslintConfigs.strict,
  importPlugin.flatConfigs.recommended,
  importPlugin.flatConfigs.typescript,
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
      'node_modules/*',
      'public/vite-admin/*',
      'public/vite/*',
    ],
  },
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        Routes: false,
      },

      parser,
      ecmaVersion: 5,
      sourceType: 'module',

      parserOptions: {
        parser: '@typescript-eslint/parser',
      },
    },

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
      '@typescript-eslint/no-floating-promises': 'off',
      '@typescript-eslint/no-unused-vars': 'off',
      'arrow-parens': 'off',
      'function-paren-newline': 'off',
      'import/extensions': [
        'error',
        'ignorePackages',
        {
          js: 'never',
          ts: 'never',
        },
      ],
      'import/no-extraneous-dependencies': 'off',
      'import/no-unresolved': [
        'error',
        {
          ignore: ['chartjs-adapter-luxon', 'vue-chartjs'],
        },
      ],
      'import/prefer-default-export': 'off',
      'newline-per-chained-call': 'off',
      'no-alert': 'off',
      'no-console': 'warn',
      'no-debugger': 'warn',
      'no-else-return': 'off',
      'no-new': 'off',
      'no-param-reassign': 'off',
      'no-plusplus': 'off',
      'no-restricted-imports': [
        'error',
        {
          paths: [
            {
              name: 'lodash',
              message: 'Use lodash-es.',
            },
          ],
        },
      ],
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
      'vue/multi-word-component-names': 'off',
    },
  },
);
