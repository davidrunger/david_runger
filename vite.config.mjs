/* eslint-env node */

import path from 'path';
import vue from '@vitejs/plugin-vue';
import ElementPlus from 'unplugin-element-plus/vite';
import { defineConfig } from 'vite';
import FullReload from 'vite-plugin-full-reload';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  logLevel: 'warn',
  plugins: [
    FullReload([
      'app/assets/stylesheets/**/*',
      'app/decorators/**/*',
      'app/helpers/**/*',
      'app/views/**/*',
    ]),
    RubyPlugin(),
    ElementPlus(),
    vue(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/javascript'),
      img: path.resolve(__dirname, './app/assets/images'),
      css: path.resolve(__dirname, './app/assets/stylesheets'),
    },
  },
});
