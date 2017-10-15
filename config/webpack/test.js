const nodeExternals = require('webpack-node-externals');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const testConfig = merge(environment.toWebpackConfig(), shared, {
  externals: [nodeExternals()],
  devtool: 'inline-cheap-module-source-map',
});

module.exports = testConfig;
