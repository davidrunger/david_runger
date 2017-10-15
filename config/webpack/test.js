const fs = require('fs');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const testConfig = merge(environment.toWebpackConfig(), shared);

// this is needed by eslint-import-resolver-webpack to resolve paths
fs.writeFileSync('webpack.config.js', `module.exports = ${JSON.stringify(testConfig)}`);

module.exports = testConfig;
