<template lang="pug">
.chart-container
  LineChart(
    :chart-data="chartMetadata"
    :height="300"
  )
</template>

<script setup lang="ts">
import { sortBy } from 'lodash-es';
import { computed, type PropType } from 'vue';

import LineChart from '@/components/charts/LineChart.vue';
import type { Log } from '@/logs/types';

const props = defineProps({
  log: {
    type: Object as PropType<Log>,
    required: true,
  },
});

const logEntriesToChartData = computed(() => {
  return sortBy(props.log.log_entries, 'created_at').map((logEntry) => ({
    x: logEntry.created_at,
    y: logEntry.data,
    note: logEntry.note,
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
