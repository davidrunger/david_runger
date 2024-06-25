import { createPinia } from 'pinia';

import Home from '@/home/home.vue';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(Home);
const pinia = createPinia();
app.use(pinia);
