/* eslint-env node */

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/javascript/**/*.vue',
    './app/views/**/*.{erb,haml}',
    './public/*.html',
  ],
  theme: {
    extend: {
      lineHeight: {
        unset: 'unset',
      },
    },
  },
  plugins: [],
  corePlugins: {
    preflight: true,
  },
};
