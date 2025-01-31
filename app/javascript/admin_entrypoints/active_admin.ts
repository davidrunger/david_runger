import '@/shared/global_jquery';
import 'jquery-ui';
import 'jquery-ui/ui/widgets/mouse';
import '@activeadmin/activeadmin';

import ChartJSAuto from 'chart.js/auto';
import Chartkick from 'chartkick';

import 'chartjs-adapter-luxon';

Chartkick.use(ChartJSAuto);
