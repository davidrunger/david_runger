const fs = require('fs');
const { resolve } = require('path');
const { merge } = require('webpack-merge');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.append('style', {
  test: /\.(scss|sass|css)$/,
  use: [
    MiniCssExtractPlugin.loader,
    {
      loader: 'css-loader',
      options: {
        sourceMap: true,
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
  ]
});

const testConfig = merge(environment.toWebpackConfig(), shared, {
  mode: 'development',
  devtool: 'inline-cheap-module-source-map',
  devServer: {
    stats: 'minimal',
  },
  module: {
    rules: [
      {
        test: /\.html$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              esModule: false,
              name: '[name].[ext]',
            },
          },
        ],
      },
    ],
  },
  output: {
    filename: '[name].js',
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
    }),
  ],
  resolve: {
    modules: [
      resolve(__dirname, '../../app/javascript'),
    ],
  },
});

const testConfigForStaticFile = Object.assign({}, testConfig);
// don't try to write unserializable plugin; causes eslint-plugin-import resolving to fail
testConfigForStaticFile.resolve.plugins = [];

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(testConfigForStaticFile)}`,
);

module.exports = testConfig;
