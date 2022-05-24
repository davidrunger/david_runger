<template lang='pug'>
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script>
import LineChart from '@/components/charts/line_chart.vue';

export default {
  components: {
    LineChart,
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
      return this.log_entries.map(logEntry => ({
        x: logEntry.created_at,
        y: logEntry.data,
        note: logEntry.note,
      }));
    },
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
