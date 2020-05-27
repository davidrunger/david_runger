import { Line, mixins } from 'vue-chartjs';
import _ from 'lodash';

export const datasetDefaults = {
  datasets: [{
    borderColor: '#1c76c4',
    borderWidth: 2,
    fill: false,
    pointBackgroundColor: 'rgba(90, 168, 237, 0.65)',
    pointBorderColor: 'rgba(90, 168, 237, 0.65)',
    pointRadius: 2,
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
    xAxes: [{
      ...axisOptions,
      type: 'time',
      time: {
        tooltipFormat: 'MMMM DD YYYY, h:mma',
      },
    }],
    yAxes: [axisOptions],
  },
  tooltips: {
    callbacks: {
      afterBody(tooltipItems, data) {
        return data.datasets[0].data[tooltipItems[0].index].note;
      },
    },
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
