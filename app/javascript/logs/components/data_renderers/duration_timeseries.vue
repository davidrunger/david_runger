<template lang='pug'>
.chart-container
  LineChart(
    :chart-data='chartMetadata'
    :height='300'
    :options='CHART_OPTIONS'
  )
</template>

<script>
import LineChart from '@/components/charts/line_chart.vue';

function epochMsToHhMmSs(epochMs) {
  return new Date(epochMs).
    toISOString().
    substr(11, 8).
    replace(/^00:/, '').
    replace(/^0+/, '').
    replace(/^:00$/, '0');
}

function shortTimeStringToHhMmSsString(timeString) {
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

export default {
  components: {
    LineChart,
  },

  computed: {
    chartMetadata() {
      return {
        datasets: [{
          data: this.logEntriesToChartData,
        }],
      };
    },

    logEntriesToChartData() {
      return this.log_entries.map(logEntry => ({
        x: logEntry.created_at,
        y: new Date(`1970-01-01T${shortTimeStringToHhMmSsString(logEntry.data)}Z`),
        note: logEntry.note,
      }));
    },
  },

  created() {
    this.CHART_OPTIONS = {
      plugins: {
        tooltip: {
          callbacks: {
            label(tooltipItem) {
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
          afterTickToLabelConversion(axis) {
            axis.ticks = axis.ticks.map(tick => ({ ...tick, label: epochMsToHhMmSs(tick.value) }));
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
      type: Array,
      required: true,
    },
  },
};
</script>
