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
      { loader: 'sass-loader', options: { sourceMap: false } },
    ],
  }),
});

const productionConfig = merge(environment.toWebpackConfig(), shared, {
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    extractCSS,
  ],
});

module.exports = productionConfig;
