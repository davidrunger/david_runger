<template lang='pug'>
.chart-container
  line-chart(
    :chart-data='chartMetadata'
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

  computed: {
    chartMetadata() {
      return {
        datasets: [{
          label: this.data_label,
          fill: false,
          data: this.logEntriesToChartData,
        }],
      };
    },

    logEntriesToChartData() {
      return this.log_entries.map(logEntry => ({
        t: logEntry.created_at,
        y: logEntry.data[this.data_label],
      }))
    },
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
    data_label: {
      type: String,
      required: true,
    },
    log_entries: {
      type: Array,
      required: true,
    },
  },
};
</script>
