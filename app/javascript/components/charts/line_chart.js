import { Line, mixins } from 'vue-chartjs';
import _ from 'lodash';

export const datasetDefaults = {
  datasets: [{
    borderColor: '#8dc5f7',
    fill: false,
  }],
};

const axisOptions = {
  gridLines: {
    color: 'rgba(255, 255, 255, 0.2)',
  },
  ticks: {
    fontColor: '#aaa',
  },
};

export const optionsDefaults = {
  legend: {
    display: false,
  },
  maintainAspectRatio: false,
  responsive: true,
  scales: {
    xAxes: [axisOptions],
    yAxes: [axisOptions],
  },
};

export default {
  extends: Line,
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
