const { basename, dirname, join, relative, resolve } = require('path');
const { sync } = require('glob');
const extname = require('path-complete-extname');
const { settings } = require('./configuration.js');
const { VueLoaderPlugin } = require('vue-loader');

const extensionGlob = `**/*{${settings.extensions.join(',')}}*`;
const entryPath = join(settings.source_path, settings.source_entry_path);
const packPaths = sync(join(entryPath, extensionGlob));

module.exports = {
  entry: packPaths.reduce(
    (map, entry) => {
      const localMap = map;
      const namespace = relative(join(entryPath), dirname(entry));
      localMap[join(namespace, basename(entry, extname(entry)))] = resolve(entry);
      return localMap;
    },
    {} // eslint-disable-line comma-dangle
  ),

  module: {
    rules: [
      {
        test: /\.webp$/,
        loader: 'file-loader',
      },
      {
        test: /\/rails_assets\/.*\.js$/,
        loader: 'script-loader',
      },
      {
        test: /\.js$|\.vue$/,
        enforce: 'pre',
        exclude: /node_modules/,
        loader: 'eslint-loader',
        options: {},
      },
      {
        test: /\.pug$/,
        loader: 'pug-plain-loader',
      },
    ],
  },

  plugins: [
    new VueLoaderPlugin(),
  ],

  resolve: {
    alias: {
      img: resolve(__dirname, '../../app/assets/images'),
      css: resolve(__dirname, '../../app/assets/stylesheets'),
    },
    extensions: settings.extensions,
    modules: ['spec/javascript'],
  },

  resolveLoader: {
    modules: [],
  },
};
