<template lang="pug">
.chart-container
  BarGraph(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue';

import BarGraph from '@/components/charts/BarGraph.vue';
import { LogEntry } from '@/logs/types';

export default defineComponent({
  components: {
    BarGraph,
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
      const countByDate: { [key: string]: number } = {};

      for (const logEntry of this.logEntries) {
        const date = new Date(logEntry.created_at);
        const dateIsoStringInLocalTime = new Date(
          date.getTime() - date.getTimezoneOffset() * 60 * 1000,
        )
          .toISOString()
          .slice(0, 10);

        countByDate[dateIsoStringInLocalTime] =
          countByDate[dateIsoStringInLocalTime] || 0;
        countByDate[dateIsoStringInLocalTime] += logEntry.data as number;
      }

      return Object.entries(countByDate).map(([date, count]) => ({
        x: date,
        y: count,
      }));
    },
  },
});
</script>
