const fs = require('fs');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
});

// this is needed by eslint-import-resolver-webpack to resolve paths
fs.writeFileSync('webpack.config.js', `module.exports = ${JSON.stringify(developmentConfig)}`);

module.exports = developmentConfig;
