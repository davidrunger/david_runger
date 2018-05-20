<template lang='pug'>
.chart-container
  line-chart(
    :chart-data='data'
    :height='300'
    :options='CHART_OPTIONS'
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
      legend: {
        display: false,
      },
      maintainAspectRatio: false,
      responsive: true,
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

<style scoped>
.chart-container {
  margin: 0 auto; /* flex centering doesn't seem to work for some reason */
  width: 600px;
}
</style>
