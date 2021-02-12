import { renderApp } from '@/shared/customized_vue';
import { createStore, createLogger } from 'vuex';
import { useAxios } from '@/shared/axios';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import WorkoutApp from '@/workout/workout.vue';
import storeDefinition from '@/workout/store';

const app = renderApp(WorkoutApp, { storeDefinition });

app.component('Modal', Modal);
useAxios(app);
useElementPlus(app);

const store = createStore({
  ...storeDefinition,
  // log Vuex updates to console since Vue Chrome extension doesn't yet support Vuex in Vue 3
  plugins: (process.env.NODE_ENV === 'development') ? [createLogger()] : [],
});
app.use(store);
