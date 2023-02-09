<template lang='pug'>
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

<script lang='ts'>
import { Bar } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title, Tooltip, BarElement, LinearScale, TimeScale, ChartData, ChartOptions,
} from 'chart.js';
import { merge } from 'lodash-es';

ChartJS.register(
  Title, Tooltip, BarElement, LinearScale, TimeScale,
);

const commonAxisOptions = {
  grid: {
    color: 'rgba(255, 255, 255, 0.2)',
  },
  fontColor: '#aaa',
};

const datasetDefaults = {
  datasets: [{
    backgroundColor: 'rgba(90, 168, 237, 0.85)',
  }],
};

export default {
  name: 'BarChart',

  components: { Bar },

  computed: {
    mergedChartData(): ChartData<'bar', (number | [number, number] | null)[], unknown> {
      return merge(
        {},
        datasetDefaults,
        this.chartData,
      ) as ChartData<'bar', (number | [number, number] | null)[], unknown>;
    },
  },

  data() {
    return {
      chartOptions: {
        responsive: true,
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
      } as ChartOptions<'bar'>,
    };
  },

  props: {
    chartData: {
      type: Object,
      required: true,
    },
    chartId: {
      type: String,
      default: 'bar-chart',
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
  },
};
</script>
