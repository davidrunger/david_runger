/* eslint-disable global-require */

if (process.env.NODE_ENV === 'production') {
  module.exports = require('./config/webpack/production.js');
} else {
  module.exports = require('./config/webpack/development.js');
}
