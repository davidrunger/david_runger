<template lang="pug">
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script lang="ts">
import { PropType } from 'vue';

import LineChart from '@/components/charts/line_chart.vue';
import { LogEntry } from '@/logs/types';

export default {
  components: {
    LineChart,
  },

  computed: {
    chartMetadata() {
      return {
        datasets: [
          {
            label: this.data_label,
            data: this.logEntriesToChartData,
          },
        ],
      };
    },

    logEntriesToChartData() {
      return this.log_entries.map((logEntry) => ({
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
      type: Array as PropType<Array<LogEntry>>,
      required: true,
    },
  },
};
</script>
