import { renderGanttCharts } from '@/ci_step_results/renderGanttCharts';
import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { CiStepResultsIndexBootstrap } from '@/types/bootstrap/CiStepResultsIndexBootstrap';

const bootstrap = untypedBootstrap as CiStepResultsIndexBootstrap;

renderGanttCharts(bootstrap.recent_gantt_chart_metadatas);
