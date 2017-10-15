const merge = require('webpack-merge');
const StyleLintPlugin = require('stylelint-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
  plugins: [
    new StyleLintPlugin(),
  ],
});

module.exports = developmentConfig;
