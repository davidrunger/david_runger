/* eslint-env node */

import path from 'path';
import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';
import ElementPlus from 'unplugin-element-plus/vite';
import { defineConfig } from 'vite';
import FullReload from 'vite-plugin-full-reload';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  build: {
    rollupOptions: {
      maxParallelFileOps:
        (
          process.env.CI &&
          process.env.VITE_RUBY_PUBLIC_OUTPUT_DIR == 'vite-admin'
        ) ?
          1
        : 3,
    },
  },
  // https://github.com/vitejs/vite/issues/ 18164#issuecomment-2365310242
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern-compiler',
      },
    },
  },
  logLevel: process.env.CI ? 'warn' : undefined,
  plugins: [
    tailwindcss(),
    FullReload([
      'app/assets/stylesheets/**/*',
      'app/controllers/**/*',
      'app/decorators/**/*',
      'app/helpers/**/*',
      'app/presenters/**/*',
      'app/views/**/*',
    ]),
    RubyPlugin(),
    ElementPlus(),
    vue({
      template: {
        compilerOptions: {
          // Treat all tags with a dash as custom elements.
          isCustomElement: (tag) => tag.includes('-'),
          whitespace: 'preserve',
        },
      },
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/javascript'),
      img: path.resolve(__dirname, './app/assets/images'),
      css: path.resolve(__dirname, './app/assets/stylesheets'),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    server: {
      deps: {
        inline: ['element-plus'],
      },
    },
  },
});
