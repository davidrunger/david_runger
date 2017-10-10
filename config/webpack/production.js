const webpack = require('webpack');
const merge = require('webpack-merge');
const environment = require('./environment');

module.exports = merge(environment.toWebpackConfig(), {
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
  ],
});
