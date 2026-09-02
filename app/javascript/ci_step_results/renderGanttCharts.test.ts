import {
  Tooltip,
  type Chart,
  type ChartConfiguration,
  type Color,
} from 'chart.js';

import { renderGanttCharts } from './renderGanttCharts';

const chartConstructor = vi.hoisted(() =>
  vi.fn((..._arguments: Array<unknown>) => undefined),
);
const register = vi.hoisted(() => vi.fn());

vi.mock('chart.js', () => ({
  BarController: {},
  BarElement: {},
  CategoryScale: {},
  Chart: Object.assign(
    function ChartJSMock(...arguments_: Array<unknown>) {
      chartConstructor(...arguments_);
    },
    { register },
  ),
  TimeScale: {},
  Tooltip: { positioners: {} },
}));
vi.mock('chartjs-adapter-luxon', () => ({}));

type GanttChartConfiguration = ChartConfiguration<
  'bar',
  Array<[number, number]>,
  string
>;

function renderedConfiguration(index: number) {
  return chartConstructor.mock.calls[index][1] as GanttChartConfiguration;
}

function colorsByStep(configuration: GanttChartConfiguration) {
  const colors = configuration.data.datasets[0].backgroundColor as Array<Color>;

  return new Map(
    configuration.data.labels?.map((stepName, index) => [
      stepName,
      colors[index],
    ]),
  );
}

describe('renderGanttCharts', () => {
  beforeEach(() => {
    chartConstructor.mockClear();
    document.body.innerHTML = '<div id="first"></div><div id="second"></div>';
  });

  afterEach(() => {
    document.body.replaceChildren();
  });

  it('renders sorted floating bars with stable colors for each step name', () => {
    renderGanttCharts([
      {
        dom_id: 'first',
        run_times: [
          {
            name: 'PnpmInstall',
            seconds: 10,
            started_at: '2026-08-30T12:00:20Z',
            stopped_at: '2026-08-30T12:00:30Z',
          },
          {
            name: 'SetupDB',
            seconds: 5,
            started_at: '2026-08-30T12:00:10Z',
            stopped_at: '2026-08-30T12:00:15Z',
          },
        ],
      },
      {
        dom_id: 'second',
        run_times: [
          {
            name: 'PnpmInstall',
            seconds: 8,
            started_at: '2026-08-30T12:01:00Z',
            stopped_at: '2026-08-30T12:01:08Z',
          },
          {
            name: 'SetupDB',
            seconds: 4,
            started_at: '2026-08-30T12:01:10Z',
            stopped_at: '2026-08-30T12:01:14Z',
          },
        ],
      },
    ]);

    expect(chartConstructor).toHaveBeenCalledTimes(2);
    expect(document.querySelectorAll('canvas')).toHaveLength(2);
    expect(
      document.querySelector<HTMLElement>('#first > div')?.style.height,
    ).toBe('94px');

    const firstConfiguration = renderedConfiguration(0);
    const secondConfiguration = renderedConfiguration(1);

    expect(firstConfiguration.data.labels).toEqual(['SetupDB', 'PnpmInstall']);
    expect(firstConfiguration.data.xLabels).toEqual([]);
    expect(firstConfiguration.data.datasets[0].data).toEqual([
      [Date.parse('2026-08-30T12:00:10Z'), Date.parse('2026-08-30T12:00:15Z')],
      [Date.parse('2026-08-30T12:00:20Z'), Date.parse('2026-08-30T12:00:30Z')],
    ]);
    expect(colorsByStep(firstConfiguration)).toEqual(
      colorsByStep(secondConfiguration),
    );
    expect(firstConfiguration.options?.scales?.x).toMatchObject({
      position: 'bottom',
      time: { minUnit: 'second', unit: 'second' },
      type: 'time',
    });
    expect(firstConfiguration.options?.plugins?.tooltip?.position).toBe(
      'ganttCursor',
    );
    expect(Tooltip.positioners.ganttCursor([], { x: 120, y: 40 })).toEqual({
      x: 120,
      y: 40,
    });
  });

  it('draws a minor grid line for every second', () => {
    renderGanttCharts([
      {
        dom_id: 'first',
        run_times: [
          {
            name: 'SetupDB',
            seconds: 5,
            started_at: '2026-08-30T12:00:00Z',
            stopped_at: '2026-08-30T12:00:05Z',
          },
        ],
      },
    ]);

    const configuration = renderedConfiguration(0);
    const minorSecondGridPlugin = configuration.plugins?.find(
      ({ id }) => id === 'minorSecondGrid',
    );
    const getPixelForValue = vi.fn((value: number) => value / 100);
    const ctx = {
      beginPath: vi.fn(),
      lineTo: vi.fn(),
      moveTo: vi.fn(),
      restore: vi.fn(),
      save: vi.fn(),
      stroke: vi.fn(),
    };
    const chart = {
      chartArea: { bottom: 120, top: 20 },
      ctx,
      scales: {
        x: { getPixelForValue, max: 5_500, min: 500 },
      },
    } as unknown as Chart<'bar'>;

    if (!minorSecondGridPlugin?.beforeDraw) {
      throw new Error('Expected the minor-second grid plugin');
    }

    minorSecondGridPlugin.beforeDraw(chart, { cancelable: true }, {});

    expect(getPixelForValue.mock.calls).toEqual([
      [1_000],
      [2_000],
      [3_000],
      [4_000],
      [5_000],
    ]);
    expect(ctx.moveTo.mock.calls).toEqual([
      [10, 20],
      [20, 20],
      [30, 20],
      [40, 20],
      [50, 20],
    ]);
    expect(ctx.lineTo.mock.calls).toEqual([
      [10, 120],
      [20, 120],
      [30, 120],
      [40, 120],
      [50, 120],
    ]);
  });
});
