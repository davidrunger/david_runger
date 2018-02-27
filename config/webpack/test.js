const fs = require('fs');
const { resolve } = require('path');
const merge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.set('vue', {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader',
      scss: 'vue-style-loader!css-loader!postcss-loader!sass-loader',
      sass: 'vue-style-loader!css-loader!postcss-loader!sass-loader?indentedSyntax',
    },
  },
});

const extractCSS = new ExtractTextPlugin('[name].css');
environment.loaders.set('style', {
  test: /\.(scss|sass|css)$/,
  use: extractCSS.extract({
    use: [
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
  }),
});

const testConfig = merge(environment.toWebpackConfig(), shared, {
  mode: 'development',
  devtool: 'inline-cheap-module-source-map',
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
  plugins: [extractCSS],
  resolve: {
    modules: [
      resolve(__dirname, '../../app/javascript'),
    ],
  },
});

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(testConfig)}`,
);

module.exports = testConfig;
