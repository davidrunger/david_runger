require('jsdom-global')(); // eslint-disable-line import/no-extraneous-dependencies
global.expect = require('expect'); // eslint-disable-line import/no-extraneous-dependencies

const originalConsoleError = console.error;
console.error = (...args) => {
  originalConsoleError(args);
  throw new Error('console.error was called - throwing error');
}
