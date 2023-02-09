<template lang="pug">
VueLine(
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
import { Line as VueLine } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Tooltip, LineElement, LinearScale, PointElement, TimeScale, ChartData, Point, TooltipItem,
  ChartOptions,
} from 'chart.js';
import 'chartjs-adapter-luxon';
import { merge } from 'lodash-es';

ChartJS.register(
  Tooltip, LineElement, LinearScale, PointElement, TimeScale,
);

const datasetDefaults = {
  datasets: [{
    borderColor: '#1c76c4',
    borderWidth: 2,
    fill: false,
    pointBackgroundColor: 'rgba(90, 168, 237, 0.65)',
    pointBorderColor: 'rgba(90, 168, 237, 0.65)',
    pointRadius: 2,
  }],
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

export default {
  name: 'LineChart',

  components: { VueLine },

  computed: {
    chartOptions() {
      return merge({}, chartOptionsDefaults, this.options) as ChartOptions<'line'>;
    },

    mergedChartData(): ChartData<'line', (number | Point | null)[], unknown> {
      return merge(
        {},
        datasetDefaults,
        this.chartData,
      ) as ChartData<'line', (number | Point | null)[], unknown>;
    },
  },

  props: {
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
  },
};
</script>
