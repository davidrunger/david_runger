<template lang="pug">
.chart-container
  BarGraph(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script lang="ts">
import { PropType } from 'vue';

import BarGraph from '@/components/charts/bar_graph.vue';
import { LogEntry } from '@/logs/types';

export default {
  components: {
    BarGraph,
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
      const countByDate: { [key: string]: number } = {};

      for (const logEntry of this.log_entries) {
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
