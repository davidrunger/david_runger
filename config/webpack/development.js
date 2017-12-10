const webpack = require('webpack');
const fs = require('fs');
const merge = require('webpack-merge');
const StyleLintPlugin = require('stylelint-webpack-plugin');
const environment = require('./environment');
const shared = require('./shared');

environment.loaders.set('vue', {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader',
      file: 'file-loader',
      scss: 'vue-style-loader!css-loader!postcss-loader!sass-loader',
      sass: 'vue-style-loader!css-loader!postcss-loader!sass-loader?indentedSyntax',
    },
  },
});

environment.loaders.set('style', {
  test: /\.(scss|sass|css)$/,
  use: [
    'style-loader',
    {
      loader: 'css-loader',
      options: {
        hmr: true,
        minimize: false,
        sourceMap: true,
        convertToAbsoluteUrls: true,
      },
    },
    'postcss-loader',
    {
      loader: 'sass-loader',
      options: {
        sourceMap: true,
      },
    },
  ],
});

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  devtool: 'inline-cheap-module-source-map',
  plugins: [
    new StyleLintPlugin(),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'commons',
      filename: 'commons-[hash].js',
      minChunks: 2,
    }),
  ],
});

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(developmentConfig)}`,
);

module.exports = developmentConfig;
