/* global process */

import path from 'path';
import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';
import ElementPlus from 'unplugin-element-plus/vite';
import { defineConfig } from 'vite';
import FullReload from 'vite-plugin-full-reload';
import RubyPlugin from 'vite-plugin-ruby';

// Translate the legacy option until vite-plugin-ruby returns `server.ws`.
function RubyPluginWithWebSocketConfig() {
  return RubyPlugin().map((plugin) => {
    if (
      plugin.name !== 'vite-plugin-ruby' ||
      typeof plugin.config !== 'function'
    )
      return plugin;

    return {
      ...plugin,
      config(...args) {
        const config = plugin.config.apply(this, args);
        const { hmr, ...server } = config.server;
        const userWebSocketConfig = args[0]?.server?.ws;

        if (!hmr || server.ws) return config;

        return {
          ...config,
          server: {
            ...server,
            ws: {
              ...hmr,
              ...(userWebSocketConfig &&
                typeof userWebSocketConfig === 'object' &&
                userWebSocketConfig),
            },
          },
        };
      },
    };
  });
}

export default defineConfig(({ mode }) => ({
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
    RubyPluginWithWebSocketConfig(),
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
      '@': path.resolve(import.meta.dirname, './app/javascript'),
      img: path.resolve(import.meta.dirname, './app/assets/images'),
      css: path.resolve(import.meta.dirname, './app/assets/stylesheets'),
      ...(mode === 'production' && {
        'vue-types': 'vue-types/shim',
      }),
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
}));
