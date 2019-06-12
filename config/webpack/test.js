const fs = require('fs');
const { resolve } = require('path');
const merge = require('webpack-merge');
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
    // from https://github.com/webpack/webpack/issues/708#issuecomment-70869174
    function () {
      this.hooks.done.tap('RungerTestEnvErrorLogger', stats => {
        if (stats.compilation.errors && stats.compilation.errors.length && process.env.TRAVIS) {
          console.error(stats.compilation.errors);
          process.exit(1);
        }
      });
    },
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
