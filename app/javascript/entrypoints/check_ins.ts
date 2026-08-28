import { createPinia } from 'pinia';

import CheckIns from '@/check_ins/App.vue';
import { renderApp } from '@/lib/customizedVue';

const app = renderApp(CheckIns, '#check_ins_app');
const pinia = createPinia();
app.use(pinia);
