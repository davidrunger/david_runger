const webpack = require('webpack');
const merge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

const cssExtractOptions = ExtractTextPlugin.extract({
  use: [
    { loader: 'css-loader', options: { minimize: true, sourceMap: false } },
    { loader: 'postcss-loader', options: { sourceMap: false } },
    { loader: 'sass-loader', options: { sourceMap: false } },
  ],
});

environment.loaders.append('style', {
  test: /\.(scss|sass|css)$/,
  use: cssExtractOptions,
});

const environmentConfig = environment.toWebpackConfig();
delete environmentConfig.devtool; // added by webpacker, but we want to use SourceMapDevToolPlugin

const productionConfig = merge(environmentConfig, shared, {
  mode: 'production',
  output: {
    devtoolModuleFilenameTemplate: info => {
      let path = info.resourcePath;
      // replace leading dot with `/app` since that's where Heroku keeps our app
      path = path.replace(/^\./, '/app');
      // exclude node_modules from in-project stack trace
      return path.replace(/^\/app\/node_modules/, '/vendor/node_modules');
    },
  },
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    new ExtractTextPlugin({
      filename: '[name]-[contenthash].css',
      allChunks: true,
    }),
    new webpack.SourceMapDevToolPlugin({
      test: /\.(js|vue)/,
      filename: '[file].map[query]',
      append: false,
    }),
  ],
});

module.exports = productionConfig;
