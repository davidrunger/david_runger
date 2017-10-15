const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
});

module.exports = developmentConfig;
