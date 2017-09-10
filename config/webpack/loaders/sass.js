const ExtractTextPlugin = require('extract-text-webpack-plugin')
const { env } = require('../configuration.js')

let use = [];

use.push(
  { loader: 'css-loader', options: { minimize: (env.NODE_ENV === 'production') } },
  { loader: 'postcss-loader', options: { sourceMap: true } },
  'resolve-url-loader',
  { loader: 'sass-loader', options: { sourceMap: true } }
);

if (env.NODE_ENV !== 'production' ) {
  use.unshift('style-loader');
}

if (env.NODE_ENV === 'production' ) {
  use = ExtractTextPlugin.extract({
    fallback: 'style-loader',
    use: use,
  });
}

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: use,
}
