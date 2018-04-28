const webpack = require('webpack');
const fs = require('fs');
const merge = require('webpack-merge');
const StyleLintPlugin = require('stylelint-webpack-plugin');

const environment = require('./environment');
const shared = require('./shared');

environment.loaders.append('style', {
  test: /\.(scss|sass|css)$/,
  use: [
    {
      loader: 'style-loader',
      options: {
        sourceMap: true,
      },
    },
    {
      loader: 'css-loader',
      options: {
        hmr: true,
        minimize: false,
        sourceMap: true,
        convertToAbsoluteUrls: true,
      },
    },
    {
      loader: 'postcss-loader',
      options: {
        sourceMap: true,
      },
    },
    {
      loader: 'sass-loader',
      options: {
        sourceMap: true,
      },
    },
  ],
});

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  mode: 'development',
  devServer: {
    stats: 'minimal',
  },
  devtool: 'inline-cheap-module-source-map',
  plugins: [
    new StyleLintPlugin({
      files: ['**/*.vue', '**/*.css', '**/*.scss'],
    }),
  ],
});

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(developmentConfig)}`,
);

module.exports = developmentConfig;
