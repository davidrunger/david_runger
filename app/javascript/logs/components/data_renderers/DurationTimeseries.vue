<template lang="pug">
.chart-container
  LineChart(
    :chart-data='chartMetadata',
    :height='300',
    :options='CHART_OPTIONS'
  )
</template>

<script setup lang="ts">
import type { CoreScaleOptions, Scale, TooltipItem } from 'chart.js';
import { sortBy } from 'lodash-es';
import { computed, type PropType } from 'vue';

import LineChart from '@/components/charts/LineChart.vue';
import type { Log } from '@/logs/types';
import type { LogEntry } from '@/types';

function epochMsToHhMmSs(epochMs: number) {
  return new Date(epochMs)
    .toISOString()
    .substring(11, 19)
    .replace(/^00:/, '')
    .replace(/^0+/, '')
    .replace(/^:00$/, '0');
}

function shortTimeStringToHhMmSsString(timeString: string) {
  switch (timeString.length) {
    case 1:
      return `00:00:0${timeString}`;
    case 2:
      return `00:00:${timeString}`;
    case 4:
      return `00:0${timeString}`;
    case 5:
      return `00:${timeString}`;
    case 7:
      return `0${timeString}`;
    default:
      return timeString;
  }
}

type ChartData = {
  x: string;
  y: Date;
  note: string | null;
};

const props = defineProps({
  log: {
    type: Object as PropType<Log>,
    required: true,
  },
});

const CHART_OPTIONS = {
  plugins: {
    tooltip: {
      callbacks: {
        label(tooltipItem: TooltipItem<'line'>) {
          return epochMsToHhMmSs(tooltipItem.parsed.y);
        },
      },
    },
  },
  scales: {
    x: {
      type: 'time',
      ticks: {
        minRotation: 52,
        source: 'auto',
      },
    },
    y: {
      afterTickToLabelConversion(axis: Scale<CoreScaleOptions>) {
        axis.ticks = axis.ticks.map((tick) => ({
          ...tick,
          label: epochMsToHhMmSs(tick.value),
        }));
      },
    },
  },
};

const logEntriesToChartData = computed((): Array<ChartData> => {
  return sortBy(props.log.log_entries, 'created_at').map(
    (logEntry: LogEntry): ChartData => ({
      x: logEntry.created_at,
      y: new Date(
        `1970-01-01T${shortTimeStringToHhMmSsString(logEntry.data as string)}Z`,
      ),
      note: logEntry.note,
    }),
  );
});

const chartMetadata = computed(
  (): { datasets: Array<{ data: Array<ChartData> }> } => {
    return {
      datasets: [
        {
          data: logEntriesToChartData.value,
        },
      ],
    };
  },
);
</script>
