<template lang="pug">
VueLine(
  :options="chartOptions",
  :data="mergedChartData",
  :chart-id="chartId",
  :dataset-id-key="datasetIdKey",
  :css-classes="cssClasses",
  :styles="styles",
  :width="width",
  :height="height"
)
</template>

<script setup lang="ts">
import {
  Chart as ChartJS,
  LinearScale,
  LineElement,
  PointElement,
  TimeScale,
  Tooltip,
  type ChartData,
  type ChartOptions,
  type Point,
  type TooltipItem,
} from 'chart.js';
import { merge } from 'lodash-es';
import { Line as VueLine } from 'vue-chartjs';

import 'chartjs-adapter-luxon';

import { computed } from 'vue';

ChartJS.register(Tooltip, LineElement, LinearScale, PointElement, TimeScale);

const datasetDefaults = {
  datasets: [
    {
      borderColor: '#1c76c4',
      borderWidth: 2,
      fill: false,
      pointBackgroundColor: 'rgba(90, 168, 237, 0.65)',
      pointBorderColor: 'rgba(90, 168, 237, 0.65)',
      pointRadius: 2,
    },
  ],
};

const axisOptions = {
  grid: {
    color: 'rgba(255, 255, 255, 0.2)',
  },
};

const chartOptionsDefaults = {
  legend: {
    display: false,
  },
  maintainAspectRatio: false,
  plugins: {
    tooltip: {
      callbacks: {
        afterBody(tooltipItems: Array<TooltipItem<'line'>>) {
          return (tooltipItems[0].raw as { note: string }).note;
        },
      },
    },
  },
  responsive: true,
  scales: {
    x: {
      ...axisOptions,
      type: 'time',
    },
    y: {
      ...axisOptions,
    },
  },
};

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
  options: {
    type: Object,
    default: () => {},
  },
  chartId: {
    type: String,
    default: 'line-chart',
  },
  datasetIdKey: {
    type: String,
    default: 'label',
  },
  width: {
    type: Number,
    default: 400,
  },
  height: {
    type: Number,
    default: 400,
  },
  cssClasses: {
    default: '',
    type: String,
  },
  styles: {
    type: Object,
    default: () => {},
  },
});

const chartOptions = computed(() => {
  return merge({}, chartOptionsDefaults, props.options) as ChartOptions<'line'>;
});

const mergedChartData = computed(
  (): ChartData<'line', (number | Point | null)[], unknown> => {
    return merge({}, datasetDefaults, props.chartData) as ChartData<
      'line',
      (number | Point | null)[],
      unknown
    >;
  },
);
</script>
