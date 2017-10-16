const fs = require('fs');
const { resolve } = require('path');
const merge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

const extractCSS = new ExtractTextPlugin('[name].css');

environment.loaders.set('style', {
  test: /\.(scss|sass|css)$/,
  use: extractCSS.extract({
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
  plugins: [extractCSS],
  resolve: {
    modules: [
      resolve(__dirname, '../../app/javascript'),
    ],
  },
});

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(testConfig)}`,
);

module.exports = testConfig;
