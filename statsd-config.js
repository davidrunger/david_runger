// Example w/ explanations of these and other available settings:
// https://github.com/etsy/statsd/blob/master/exampleConfig.js

//
// Local Testing Config
//
// {
//   debug: true,
//   dumpMessages: true,
//   backends: ['./backends/console'],
// }
//
// NOTE NOTE NOTE NOTE NOTE NOTE
//   The `process.env.XYZ` stuff does not work solely based off of a `.env` file.
//   Export those variables into the local environment or temporarily copy them into this file.
// NOTE NOTE NOTE NOTE NOTE NOTE
//

{
  graphite: {
    globalPrefix: process.env.GRAPHITE_SECRET,
    legacyNamespace: false, // required for globalPrefix to be applied
  },
  deleteCounters: true,
  deleteTimers: true,
  graphitePort: 2023, // using non-default (which would be 2003) bc. sending to aggregator instead
  graphiteHost: process.env.GRAPHITE_HOST,
}
