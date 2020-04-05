import { Bar, mixins } from 'vue-chartjs';
import _ from 'lodash';

export const datasetDefaults = {
  datasets: [{
    backgroundColor: 'rgba(90, 168, 237, 0.85)',
  }],
};

const commonAxisOptions = {
  gridLines: {
    color: 'rgba(255, 255, 255, 0.2)',
  },
  fontColor: '#aaa',
};

export const optionsDefaults = {
  legend: {
    display: false,
  },
  maintainAspectRatio: false,
  responsive: true,
  scales: {
    xAxes: [_.merge({}, commonAxisOptions, {
      type: 'time',
      time: {
        minUnit: 'day',
      },
    })],
    yAxes: [_.merge({}, commonAxisOptions, {
      ticks: {
        min: 0,
      },
    })],
  },
};

export default {
  extends: Bar,
  mixins: [mixins.reactiveProp],

  props: {
    // chartData is a special prop that is used by mixins.reactiveProp to make the chart reactive
    chartData: {
      type: Object,
      required: true,
    },
    options: {
      type: Object,
      required: false,
    },
  },

  mounted() {
    const datasets = _.merge({}, datasetDefaults, this.chartData);
    const options = _.merge({}, optionsDefaults, this.options);
    this.renderChart(datasets, options);
  },
};
