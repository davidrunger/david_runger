import embed, { type VisualizationSpec } from 'vega-embed';

type CiStepResult = {
  name: string;
  started_at: string;
  stopped_at: string;
};

type CiStepResultsSet = {
  dom_id: string;
  run_times: Array<CiStepResult>;
};

export function renderGanttCharts(ciStepResultsSet: Array<CiStepResultsSet>) {
  for (const ciStepResultSet of ciStepResultsSet) {
    const spec: VisualizationSpec = {
      $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
      width: 'container',
      data: { values: ciStepResultSet.run_times },
      mark: 'bar',
      encoding: {
        y: {
          field: 'name',
          type: 'nominal',
          sort: 'x', // sort tasks by start time
          axis: { title: 'Step' },
        },
        x: {
          field: 'started_at',
          type: 'temporal',
          axis: { title: 'Time' },
        },
        x2: { field: 'stopped_at' },
        color: {
          field: 'name',
          type: 'nominal',
          legend: null,
        },
        tooltip: [{ field: 'name', type: 'nominal', title: 'Step' }],
      },
    };

    embed(`#${ciStepResultSet.dom_id}`, spec);
  }
}
