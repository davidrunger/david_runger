import { renderApp } from 'shared/customized_vue';
import WorkoutApp from 'workout/workout.vue';
import store from 'workout/store';

renderApp(WorkoutApp, { store });
