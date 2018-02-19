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
