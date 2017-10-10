const { environment } = require('@rails/webpacker');

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

module.exports = environment;
