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
      { loader: 'css-loader', options: { minimize: true, sourceMap: false } },
      { loader: 'postcss-loader', options: { sourceMap: false } },
      { loader: 'sass-loader', options: { sourceMap: false } },
    ],
  }),
});

const environmentConfig = environment.toWebpackConfig();
delete environmentConfig.devtool; // added by webpacker, but we want to use SourceMapDevToolPlugin

const productionConfig = merge(environmentConfig, shared, {
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
          cssSourceMap: false,
          extractCSS: ExtractTextPlugin.extract({
            use: [
              { loader: 'css-loader', options: { minimize: true, sourceMap: false } },
              { loader: 'postcss-loader', options: { sourceMap: false } },
              { loader: 'sass-loader', options: { sourceMap: false } },
            ],
          }),
          loaders: {
            js: 'babel-loader',
            file: 'file-loader',
          },
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
    new webpack.SourceMapDevToolPlugin({
      test: /\.(js|vue)/,
      filename: '[file].map[query]',
      append: false,
    }),
  ],
});

module.exports = productionConfig;
