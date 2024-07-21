<template lang="pug">
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
  )
</template>

<script setup lang="ts">
import { sortBy } from 'lodash-es';
import { computed, type PropType } from 'vue';

import LineChart from '@/components/charts/LineChart.vue';
import type { LogEntry } from '@/logs/types';

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
  return sortBy(props.logEntries, ['created_at']).map((logEntry) => ({
    x: logEntry.created_at,
    y: logEntry.data,
    note: logEntry.note,
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
