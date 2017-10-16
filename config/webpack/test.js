const { resolve } = require('path');
const merge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.set('style', {
  test: /\.(scss|sass|css)$/,
  use: ExtractTextPlugin.extract({
    use: [
      { loader: 'css-loader', options: { minimize: false } },
      { loader: 'sass-loader', options: { sourceMap: true } },
    ],
  }),
});

const testConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
  output: {
    filename: '[name].js',
  },
  plugins: [
    new ExtractTextPlugin('[name].css'),
  ],
  resolve: {
    modules: [
      resolve(__dirname, '../../app/javascript'),
    ],
  },
});

module.exports = testConfig;
