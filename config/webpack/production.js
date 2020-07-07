const webpack = require('webpack');
const { merge } = require('webpack-merge');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.append('style', {
  test: /\.(scss|sass|css)$/,
  use: [
    MiniCssExtractPlugin.loader,
    { loader: 'css-loader', options: { sourceMap: false } },
    { loader: 'postcss-loader', options: { sourceMap: false } },
    { loader: 'sass-loader', options: { sourceMap: false } },
  ],
});

const environmentConfig = environment.toWebpackConfig();
delete environmentConfig.devtool; // added by webpacker, but we want to use SourceMapDevToolPlugin

const productionConfig = merge(environmentConfig, shared, {
  mode: 'production',
  optimization: {
    minimizer: [
      new OptimizeCSSAssetsPlugin({}),
    ],
  },
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
    new MiniCssExtractPlugin({
      filename: '[name]-[hash].css',
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
