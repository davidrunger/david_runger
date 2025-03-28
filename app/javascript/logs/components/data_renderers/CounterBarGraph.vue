<template lang="pug">
.chart-container
  BarGraph(
    :chart-data="chartMetadata"
    :height="300"
  )
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { object } from 'vue-types';

import BarGraph from '@/components/charts/BarGraph.vue';
import { assert } from '@/lib/helpers';
import type { Log } from '@/logs/types';

const props = defineProps({
  log: object<Log>().isRequired,
});

const logEntriesToChartData = computed(() => {
  const countByDate: { [key: string]: number } = {};

  for (const logEntry of assert(props.log.log_entries)) {
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
        label: props.log.data_label,
        data: logEntriesToChartData.value,
      },
    ],
  };
});
</script>
