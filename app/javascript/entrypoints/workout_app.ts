import { createPinia } from 'pinia';

import { renderApp } from '@/lib/customizedVue';
import WorkoutApp from '@/workout/Workout.vue';

const app = renderApp(WorkoutApp);
const pinia = createPinia();
app.use(pinia);
