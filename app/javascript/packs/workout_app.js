import { renderApp } from 'shared/customized_vue';
import { useElementPlus } from 'shared/element_plus';
import WorkoutApp from 'workout/workout.vue';
import storeDefinition from 'workout/store';

const app = renderApp(WorkoutApp, { storeDefinition });
useElementPlus(app);
