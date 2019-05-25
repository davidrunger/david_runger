/* eslint-disable no-console */

const { runner } = require('mocha-headless-chrome');

runner({ file: 'http://localhost:8080/packs-test/mocha_runner.html' }).
  then(({ result }) => {
    const { stats } = result;
    if (stats.passes <= 0) {
      console.error('No tests passed!');
      process.exit(1);
    }
    if (stats.failures > 0) {
      console.error(`${stats.failures} test(s) failed!`);
      process.exit(1);
    }
  }).catch(error => {
    console.error(error);
    console.error('An error occurred in the test runner!');
    process.exit(1);
  });
