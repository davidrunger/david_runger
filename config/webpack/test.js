const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

module.exports = merge(environment.toWebpackConfig(), shared);
