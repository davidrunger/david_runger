const webpack = require('webpack');
const merge = require('webpack-merge');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

const extractCSS = new ExtractTextPlugin('[name]-[contenthash].css');
environment.loaders.set('style', {
  test: /\.(scss|sass|css)$/,
  use: extractCSS.extract({
    use: [
      { loader: 'css-loader', options: { minimize: true } },
      'postcss-loader',
      { loader: 'sass-loader', options: { sourceMap: false } },
    ],
  }),
});

const productionConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'hidden-source-map', // even though it's open-source, hide to save the network requests
  output: {
    devtoolModuleFilenameTemplate: info => {
      let path = info.resourcePath;
      // replace leading dot with `/app` since that's where Heroku keeps our app
      path = path.replace(/^\./, '/app');
      // exclude node_modules from in-project stack trace
      return path.replace(/^\/app\/node_modules/, '/vendor/node_modules');
    },
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          extractCSS: true,
        },
      },
    ],
  },
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    extractCSS,
    new webpack.optimize.CommonsChunkPlugin({
      name: 'commons',
      filename: 'commons-[hash].js',
      minChunks: 2,
    }),
  ],
});

module.exports = productionConfig;
