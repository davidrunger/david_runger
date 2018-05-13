<template lang='pug'>
line-chart(
  :chart-data='data'
  :options='CHART_OPTIONS'
  :height='200'
  :width='400'
)
</template>

<script>
import LineChart from 'components/charts/line_chart';

export default {
  components: {
    LineChart,
  },

  created() {
    this.CHART_OPTIONS = {
      responsive: false,
      legend: {
        display: false,
      },
      title: {
        display: true,
        text: 'Weight',
      },
      scales: {
        xAxes: [{
          type: 'time',
          ticks: {
            minRotation: 52,
            source: 'auto',
          },
        }],
        yAxes: [
          {
            ticks: {
              suggestedMin: 167,
            },
          },
        ],
      },
    };
  },

  props: {
    data: {
      type: Object,
      required: true,
    },
  },
};
</script>
