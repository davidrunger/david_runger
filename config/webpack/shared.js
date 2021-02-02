const webpack = require('webpack');
const { basename, dirname, join, relative, resolve } = require('path');
const { sync } = require('glob');
const extname = require('path-complete-extname');
const { VueLoaderPlugin } = require('vue-loader');
const MomentLocalesPlugin = require('moment-locales-webpack-plugin');
const { settings } = require('./configuration.js');

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
        test: /\.(gif|jpg|png|svg|ttf|webp|woff)$/,
        loader: 'file-loader',
        options: {
          esModule: false,
        },
      },
      {
        test: /\/rails_assets\/.*\.js$/,
        loader: 'script-loader',
      },
      {
        test: /\.pug$/,
        loader: 'pug-plain-loader',
      },
      {
        test: /\.vue$/,
        loader: 'vue-loader',
      },
    ],
  },

  node: {
    // required because `stack-utils` depends on the node module called ... `module`
    // https://github.com/evanw/node-source-map-support/issues/ 155#issuecomment-358482159
    module: 'empty',
  },

  plugins: [
    new webpack.DefinePlugin({
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false,
    }),
    new VueLoaderPlugin(),
    // use en locale (rather than zh-CN) for element-plus
    new webpack.NormalModuleReplacementPlugin(
      /element-plus[/\\]lib[/\\]locale[/\\]lang[/\\]zh-CN/,
      'element-plus/lib/locale/lang/en',
    ),
    new MomentLocalesPlugin(),
  ],

  resolve: {
    alias: {
      img: resolve(__dirname, '../../app/assets/images'),
      css: resolve(__dirname, '../../app/assets/stylesheets'),
    },
    extensions: settings.extensions,
  },

  resolveLoader: {
    modules: [],
  },
};
