/* eslint-disable global-require */

if (process.env.NODE_ENV === 'production') {
  module.exports = require('./config/webpack/production.js');
} else if (process.env.NODE_ENV === 'test') {
  module.exports = require('./config/webpack/test.js');
} else {
  module.exports = require('./config/webpack/development.js');
}
