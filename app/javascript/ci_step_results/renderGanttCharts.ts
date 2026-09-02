import {
  BarController,
  BarElement,
  CategoryScale,
  Chart as ChartJS,
  TimeScale,
  Tooltip,
  type ChartConfiguration,
  type ChartType,
  type Plugin,
  type TooltipItem,
  type TooltipPositionerFunction,
} from 'chart.js';

import 'chartjs-adapter-luxon';

declare module 'chart.js' {
  interface TooltipPositionerMap {
    ganttCursor: TooltipPositionerFunction<ChartType>;
  }
}

type CiStepResult = {
  name: string;
  seconds: number;
  started_at: string;
  stopped_at: string;
};

type CiStepResultsSet = {
  dom_id: string;
  run_times: Array<CiStepResult>;
};

const AXIS_HEIGHT = 54;
const MAJOR_TICK_INTERVAL_SECONDS = 5;
const MILLISECONDS_PER_SECOND = 1_000;
const MINOR_GRID_COLOR = '#eeeeee';
const ROW_HEIGHT = 20;
const STEP_COLOR_PALETTE = [
  '#8faca5', // muted sage teal
  '#5c7a99', // dusty blue
  '#9fcebd', // muted mint green
  '#94bece', // muted blue
  '#ac9cc6', // muted soft violet
  '#a3849f', // mauve
  '#d8aabf', // muted bubblegum pink
  '#b18dc2', // muted light purple
  '#9bacc3', // muted powder blue
  '#d9ad8c', // muted peach
  '#d7a2aa', // muted pink
  '#afb5ce', // muted periwinkle
  '#6b9b8a', // deep seafoam
  '#5fa777', // medium green
  '#8cbeb1', // muted seafoam
  '#caa29a', // muted blush
  '#f9e07f', // pastel yellow
];

ChartJS.register(BarController, BarElement, CategoryScale, TimeScale, Tooltip);

Tooltip.positioners.ganttCursor = (_elements, eventPosition) => eventPosition;

const minorSecondGridPlugin: Plugin<'bar'> = {
  id: 'minorSecondGrid',
  beforeDraw({ chartArea, ctx, scales: { x: xScale } }) {
    const firstSecond =
      Math.ceil(xScale.min / MILLISECONDS_PER_SECOND) * MILLISECONDS_PER_SECOND;

    ctx.save();
    ctx.beginPath();
    ctx.lineWidth = 1;
    ctx.strokeStyle = MINOR_GRID_COLOR;

    for (
      let milliseconds = firstSecond;
      milliseconds <= xScale.max;
      milliseconds += MILLISECONDS_PER_SECOND
    ) {
      const xPosition = xScale.getPixelForValue(milliseconds);
      ctx.moveTo(xPosition, chartArea.top);
      ctx.lineTo(xPosition, chartArea.bottom);
    }

    ctx.stroke();
    ctx.restore();
  },
};

function colorForStep(stepName: string) {
  // FNV-1a hashes the full name into the same palette entry in every run.
  let hash = 2_166_136_261;

  for (let index = 0; index < stepName.length; index++) {
    hash ^= stepName.charCodeAt(index);
    hash = Math.imul(hash, 16_777_619);
  }

  return STEP_COLOR_PALETTE[(hash >>> 0) % STEP_COLOR_PALETTE.length];
}

function formattedTimeTick(milliseconds: number) {
  const date = new Date(milliseconds);
  const seconds = date.getSeconds();

  if (seconds !== 0) {
    return `:${seconds.toString().padStart(2, '0')}`;
  }

  const hours = date.getHours() % 12 || 12;
  const minutes = date.getMinutes().toString().padStart(2, '0');

  return `${hours}:${minutes}`;
}

function chartConfiguration(
  runTimes: Array<CiStepResult>,
): ChartConfiguration<'bar', Array<[number, number]>, string> {
  return {
    type: 'bar',
    data: {
      labels: runTimes.map(({ name }) => name),
      xLabels: [],
      datasets: [
        {
          data: runTimes.map(({ started_at, stopped_at }) => [
            Date.parse(started_at),
            Date.parse(stopped_at),
          ]),
          backgroundColor: runTimes.map(({ name }) => colorForStep(name)),
          barPercentage: 0.9,
          borderSkipped: false,
          categoryPercentage: 1,
          hoverBorderColor: '#111827',
          hoverBorderWidth: 1,
          minBarLength: 1,
        },
      ],
    },
    plugins: [minorSecondGridPlugin],
    options: {
      animation: false,
      indexAxis: 'y',
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: 'rgba(255, 255, 255, 0.96)',
          bodyColor: '#6b7280',
          borderColor: '#d1d5db',
          borderWidth: 1,
          callbacks: {
            label({ dataIndex }: TooltipItem<'bar'>) {
              return `${runTimes[dataIndex].seconds.toFixed(1)} seconds`;
            },
            title(tooltipItems: Array<TooltipItem<'bar'>>) {
              return tooltipItems[0].label;
            },
          },
          displayColors: false,
          padding: 10,
          position: 'ganttCursor',
          titleColor: '#374151',
          yAlign: 'bottom',
        },
      },
      responsive: true,
      scales: {
        x: {
          grid: { color: '#d9d9d9' },
          position: 'bottom',
          time: { minUnit: 'second', unit: 'second' },
          ticks: {
            autoSkip: true,
            callback: (value) => formattedTimeTick(Number(value)),
            maxRotation: 0,
            stepSize: MAJOR_TICK_INTERVAL_SECONDS,
          },
          title: { display: true, text: 'Time' },
          type: 'time',
        },
        y: {
          grid: { display: false },
          ticks: {
            autoSkip: false,
            font: { size: 11 },
            padding: 4,
          },
          title: { display: true, text: 'Step' },
        },
      },
    },
  };
}

export function renderGanttCharts(ciStepResultsSets: Array<CiStepResultsSet>) {
  for (const {
    dom_id: domId,
    run_times: unsortedRunTimes,
  } of ciStepResultsSets) {
    const container = document.getElementById(domId);

    if (!container) continue;

    const runTimes = unsortedRunTimes.toSorted(
      (first, second) =>
        Date.parse(first.started_at) - Date.parse(second.started_at),
    );
    const chartHeight = runTimes.length * ROW_HEIGHT + AXIS_HEIGHT;
    const chartContainer = document.createElement('div');
    chartContainer.style.height = `${chartHeight}px`;
    chartContainer.style.position = 'relative';
    chartContainer.style.width = '100%';

    const canvas = document.createElement('canvas');
    canvas.setAttribute('aria-label', 'CI step run times');
    canvas.setAttribute('role', 'img');
    chartContainer.append(canvas);
    container.replaceChildren(chartContainer);

    new ChartJS(canvas, chartConfiguration(runTimes));
  }
}
