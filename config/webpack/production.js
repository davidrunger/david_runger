const webpack = require('webpack');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

module.exports = merge(environment.toWebpackConfig(), shared, {
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
  ],
});
