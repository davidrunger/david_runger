const merge = require('webpack-merge');
const environment = require('./environment');

module.exports = merge(environment.toWebpackConfig(), {
  devtool: 'inline-cheap-module-source-map',
});
