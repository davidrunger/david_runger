import ChartJSAuto from 'chart.js/auto';
import Chartkick from 'chartkick';

import 'chartjs-adapter-luxon';

// @ts-expect-error NOTE: Importing Chartkick seems to overwrite `window.$` with
// Chartkick's `Chart` object, which is minified as `$`? Undo this.
window.$ = window.jQuery;

Chartkick.use(ChartJSAuto);
