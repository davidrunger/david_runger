const { env } = require('../configuration.js')

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: [
    'style-loader',
    { loader: 'css-loader', options: { minimize: (env.NODE_ENV === 'production') } },
    { loader: 'postcss-loader', options: { sourceMap: true } },
    'resolve-url-loader',
    { loader: 'sass-loader', options: { sourceMap: true } },
  ],
}
