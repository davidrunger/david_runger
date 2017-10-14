const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const testConfig = merge(environment.toWebpackConfig(), shared);

module.exports = testConfig;
