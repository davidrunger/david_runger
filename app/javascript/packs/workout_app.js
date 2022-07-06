import { createStore } from 'vuex';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import WorkoutApp from '@/workout/workout.vue';
import storeDefinition from '@/workout/store';

const app = renderApp(WorkoutApp);

app.component('Modal', Modal);
useKy(app);
useElementPlus(app);

const store = createStore({
  ...storeDefinition,
});
app.use(store);
