<template lang="pug">
.chart-container
  BarGraph(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script setup lang="ts">
import { computed, type PropType } from 'vue';

import BarGraph from '@/components/charts/BarGraph.vue';
import { LogEntry } from '@/types';

const props = defineProps({
  dataLabel: {
    type: String,
    required: true,
  },
  logEntries: {
    type: Array as PropType<Array<LogEntry>>,
    required: true,
  },
});

const logEntriesToChartData = computed(() => {
  const countByDate: { [key: string]: number } = {};

  for (const logEntry of props.logEntries) {
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
});

const chartMetadata = computed(() => {
  return {
    datasets: [
      {
        label: props.dataLabel,
        data: logEntriesToChartData.value,
      },
    ],
  };
});
</script>
