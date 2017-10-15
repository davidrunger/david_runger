const webpack = require('webpack');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

const productionConfig = merge(environment.toWebpackConfig(), shared, {
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
  ],
});

module.exports = productionConfig;
