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
    globalPrefix: process.env.HOSTEDGRAPHITE_APIKEY,
    legacyNamespace: false, // required for globalPrefix to be applied
  },
  graphiteHost: process.env.HOSTEDGRAPHITE_HOST,
}
