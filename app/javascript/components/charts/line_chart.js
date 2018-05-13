import { Line, mixins } from 'vue-chartjs';

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
    this.renderChart(this.chartData, this.options);
  },
};
