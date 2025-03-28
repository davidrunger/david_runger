<template lang="pug">
Bar(
  :options="chartOptions"
  :data="mergedChartData"
  :chart-id="chartId"
  :dataset-id-key="datasetIdKey"
  :css-classes="cssClasses"
  :styles="styles"
  :width="width"
  :height="height"
)
</template>

<script setup lang="ts">
import {
  BarElement,
  Chart as ChartJS,
  LinearScale,
  TimeScale,
  Title,
  Tooltip,
  type ChartData,
  type ChartOptions,
} from 'chart.js';
import { merge } from 'lodash-es';
import { computed } from 'vue';
import { Bar } from 'vue-chartjs';
import { number, object, string } from 'vue-types';

ChartJS.register(Title, Tooltip, BarElement, LinearScale, TimeScale);

const commonAxisOptions = {
  grid: {
    color: 'rgba(255, 255, 255, 0.2)',
  },
  fontColor: '#aaa',
};

const datasetDefaults = {
  datasets: [
    {
      backgroundColor: 'rgba(90, 168, 237, 0.85)',
    },
  ],
};

const props = defineProps({
  chartData: object().isRequired,
  chartId: string().def('bar-chart'),
  datasetIdKey: string().def('label'),
  width: number().def(400),
  height: number().def(400),
  cssClasses: string().def(''),
  styles: object().def(() => {}),
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    x: merge({}, commonAxisOptions, {
      offset: true,
      type: 'time',
      time: {
        minUnit: 'day',
      },
    }),
    y: merge({}, commonAxisOptions, {
      ticks: {
        min: 0,
      },
    }),
  },
} as ChartOptions<'bar'>;

const mergedChartData = computed(
  (): ChartData<'bar', (number | [number, number] | null)[], unknown> => {
    return merge({}, datasetDefaults, props.chartData) as ChartData<
      'bar',
      (number | [number, number] | null)[],
      unknown
    >;
  },
);
</script>
