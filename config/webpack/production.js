const fs = require('fs');
const webpack = require('webpack');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const productionConfig = merge(environment.toWebpackConfig(), shared, {
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
  ],
});

// this is needed by eslint-import-resolver-webpack to resolve paths
fs.writeFileSync('webpack.config.js', `module.exports = ${JSON.stringify(productionConfig)}`);

module.exports = productionConfig;
