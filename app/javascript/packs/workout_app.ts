import { createPinia } from 'pinia';
import { renderApp } from '@/shared/customized_vue';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import WorkoutApp from '@/workouts/workout.vue';

const app = renderApp(WorkoutApp);
const pinia = createPinia();
app.use(pinia);
app.component('Modal', Modal);
useElementPlus(app);
