<template lang="pug">
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue';

import LineChart from '@/components/charts/LineChart.vue';
import { LogEntry } from '@/logs/types';

export default defineComponent({
  components: {
    LineChart,
  },

  props: {
    dataLabel: {
      type: String,
      required: true,
    },
    logEntries: {
      type: Array as PropType<Array<LogEntry>>,
      required: true,
    },
  },

  computed: {
    chartMetadata() {
      return {
        datasets: [
          {
            label: this.dataLabel,
            data: this.logEntriesToChartData,
          },
        ],
      };
    },

    logEntriesToChartData() {
      return this.logEntries.map((logEntry) => ({
        x: logEntry.created_at,
        y: logEntry.data,
        note: logEntry.note,
      }));
    },
  },
});
</script>
