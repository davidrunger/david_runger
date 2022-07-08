import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ElementPlus from 'unplugin-element-plus/vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    ElementPlus(),
    vue(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/javascript'),
      'img': path.resolve(__dirname, './app/assets/images'),
      'css': path.resolve(__dirname, './app/assets/stylesheets'),
    },
  },
  server: {
    hmr: {
      port: 443,
    },
  },
})
