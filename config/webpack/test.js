const { resolve } = require('path');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const testConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
  output: {
    filename: '[name].js',
  },
  resolve: {
    modules: [
      resolve(__dirname, '../../app/javascript'),
    ],
  },
});

module.exports = testConfig;
