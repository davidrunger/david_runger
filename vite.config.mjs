/* eslint-env node */

import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import ElementPlus from 'unplugin-element-plus/vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';
import FullReload from 'vite-plugin-full-reload';

export default defineConfig({
  plugins: [
    FullReload([
      'app/views/**/*',
      'app/helpers/**/*',
      'app/assets/stylesheets/**/*',
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
