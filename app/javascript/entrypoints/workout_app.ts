import { createPinia } from 'pinia';

import Modal from '@/components/Modal.vue';
import { renderApp } from '@/shared/customized_vue';
import WorkoutApp from '@/workout/Workout.vue';

const app = renderApp(WorkoutApp);
const pinia = createPinia();
app.use(pinia);
app.component('Modal', Modal);
