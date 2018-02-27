const webpack = require('webpack');
const fs = require('fs');
const merge = require('webpack-merge');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.set('vue', {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader',
      scss:
        'vue-style-loader?sourceMap' +
        '!css-loader?sourceMap' +
        '!postcss-loader' +
        '!sass-loader',
      sass:
        'vue-style-loader?sourceMap' +
        '!css-loader?sourceMap' +
        '!postcss-loader' +
        '!sass-loader?indentedSyntax',
    },
  },
});

environment.loaders.set('style', {
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
  devtool: 'inline-cheap-module-source-map',
  plugins: [],
});

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(developmentConfig)}`,
);

module.exports = developmentConfig;
