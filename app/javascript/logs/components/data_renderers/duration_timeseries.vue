<template lang='pug'>
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
    :options='CHART_OPTIONS'
  )
</template>

<script lang='ts'>
import LineChart from '@/components/charts/line_chart.vue';
import { LogEntry } from '@/logs/types';
import { PropType } from 'vue';
import { CoreScaleOptions, Scale, TooltipItem } from 'chart.js';

function epochMsToHhMmSs(epochMs: number) {
  return new Date(epochMs).
    toISOString().
    substring(11, 19).
    replace(/^00:/, '').
    replace(/^0+/, '').
    replace(/^:00$/, '0');
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
  x: string
  y: Date
  note: string | undefined
}

export default {
  components: {
    LineChart,
  },

  computed: {
    chartMetadata(): { datasets: Array<{ data: Array<ChartData> }> } {
      return {
        datasets: [{
          data: this.logEntriesToChartData,
        }],
      };
    },

    logEntriesToChartData(): Array<ChartData> {
      return this.log_entries.map((logEntry: LogEntry): ChartData => ({
        x: logEntry.created_at,
        y: new Date(`1970-01-01T${shortTimeStringToHhMmSsString(logEntry.data as string)}Z`),
        note: logEntry.note,
      }));
    },
  },

  data() {
    return {
      CHART_OPTIONS: {
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
              axis.ticks =
                axis.ticks.map(tick => ({ ...tick, label: epochMsToHhMmSs(tick.value) }));
            },
          },
        },
      },
    };
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
