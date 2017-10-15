/* eslint-env mocha */

require('jsdom-global')(); // eslint-disable-line import/no-extraneous-dependencies
global.expect = require('expect'); // eslint-disable-line import/no-extraneous-dependencies
global._ = require('lodash');

const originalConsoleError = console.error; // eslint-disable-line no-console
beforeEach(() => {
  console.error = (...args) => { // eslint-disable-line no-console
    originalConsoleError(args);
    throw new Error('console.error was called - throwing error');
  };
});
afterEach(() => {
  console.error = originalConsoleError; // eslint-disable-line no-console
});
