import { renderApp } from 'shared/customized_vue';
import WorkoutApp from 'workout/workout.vue';
import storeDefinition from 'workout/store';

renderApp(WorkoutApp, { storeDefinition });
