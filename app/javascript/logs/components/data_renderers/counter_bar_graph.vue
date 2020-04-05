<template lang='pug'>
.chart-container
  bar-graph(
    :chart-data='chartMetadata'
    :height='300'
    :options='CHART_OPTIONS'
  )
</template>

<script>
import BarGraph from 'components/charts/bar_graph';

export default {
  components: {
    BarGraph,
  },

  computed: {
    chartMetadata() {
      return {
        datasets: [{
          label: this.data_label,
          data: this.logEntriesToChartData,
        }],
      };
    },

    logEntriesToChartData() {
      const countByDate = {};

      this.log_entries.forEach(logEntry => {
        const date = new Date(logEntry.created_at);
        const dateIsoStringInLocalTime =
          (new Date(date.getTime() - date.getTimezoneOffset() * 60 * 1000)).
            toISOString().
            slice(0, 10);

        countByDate[dateIsoStringInLocalTime] = countByDate[dateIsoStringInLocalTime] || 0;
        countByDate[dateIsoStringInLocalTime] += logEntry.data;
      });

      return Object.entries(countByDate).
        map(([date, count]) => ({
          t: date,
          y: count,
        }));
    },
  },

  created() {
    this.CHART_OPTIONS = {
      scales: {
        xAxes: [{
          type: 'time',
          ticks: {
            minRotation: 52,
            source: 'auto',
          },
        }],
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
