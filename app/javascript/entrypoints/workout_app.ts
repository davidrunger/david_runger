import { createPinia } from 'pinia';

import { renderApp } from '@/lib/customized_vue';
import WorkoutApp from '@/workout/Workout.vue';

const app = renderApp(WorkoutApp);
const pinia = createPinia();
app.use(pinia);
