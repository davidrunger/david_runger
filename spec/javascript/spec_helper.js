import _ from 'lodash';

global.expect = require('expect'); // eslint-disable-line import/no-extraneous-dependencies
global._ = require('lodash');

expect.extend({
  toExist(received) {
    const pass = (_.isInteger(received.length) && received.length > 0);
    if (pass) {
      return {
        message: () => (
          `expected ${received} not to exist (have an integer length property greater than 0)`
        ),
        pass: true,
      };
    } else {
      return {
        message: () => (
          `expected ${received} to exist (have an integer length property greater than 0)`
        ),
        pass: false,
      };
    }
  },
});

const originalConsoleError = console.error; // eslint-disable-line no-console
beforeEach(() => {
  console.error = (error) => { // eslint-disable-line no-console
    originalConsoleError(error);
    throw new Error(JSON.stringify(error));
  };
});
afterEach(() => {
  console.error = originalConsoleError; // eslint-disable-line no-console
});
