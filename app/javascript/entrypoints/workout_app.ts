import { createPinia } from 'pinia';

import { renderApp } from '@/shared/customized_vue';
import WorkoutApp from '@/workout/Workout.vue';

const app = renderApp(WorkoutApp);
const pinia = createPinia();
app.use(pinia);
