import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { fixupConfigRules, fixupPluginRules } from '@eslint/compat';
import { FlatCompat } from '@eslint/eslintrc';
import js from '@eslint/js';
import _import from 'eslint-plugin-import';
import globals from 'globals';
import parser from 'vue-eslint-parser';
import {
  defineConfigWithVueTs,
  vueTsConfigs,
} from '@vue/eslint-config-typescript';
import pluginVue from 'eslint-plugin-vue';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default defineConfigWithVueTs(
  pluginVue.configs['flat/recommended'],
  vueTsConfigs.recommendedTypeChecked,
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
  ...fixupConfigRules(
    compat.extends(
      'eslint:recommended',
      'plugin:import/typescript',
      'prettier',
    ),
  ),
  {
    plugins: {
      import: fixupPluginRules(_import),
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        Routes: false,
      },

      parser: parser,
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

      'max-len': [
        'warn',
        {
          code: 100,
          ignoreUrls: true,
        },
      ],

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

      quotes: [
        'warn',
        'single',
        {
          avoidEscape: true,
        },
      ],

      'require-await': 'error',
      'vue/multi-word-component-names': 'off',
    },
  },
);
