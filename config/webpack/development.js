const fs = require('fs');
const { merge } = require('webpack-merge');
const StyleLintPlugin = require('stylelint-webpack-plugin');

const environment = require('./environment');
const shared = require('./shared');

environment.loaders.append('style', {
  test: /\.(scss|sass|css)$/,
  use: [
    {
      loader: 'style-loader',
    },
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
  ],
});

const developmentConfig = merge(environment.toWebpackConfig(), shared, {
  mode: 'development',
  devServer: {
    stats: 'minimal',
  },
  devtool: 'inline-cheap-module-source-map',
  plugins: [
    new StyleLintPlugin({
      files: ['**/*.vue', '**/*.css', '**/*.scss'],
    }),
  ],
});

const developmentConfigForStaticFile = Object.assign({}, developmentConfig);
// don't try to write unserializable plugin; causes eslint-plugin-import resolving to fail
developmentConfigForStaticFile.resolve.plugins = [];

fs.writeFileSync(
  'webpack.config.static.js',
  `module.exports = ${JSON.stringify(developmentConfigForStaticFile)}`,
);

module.exports = developmentConfig;
