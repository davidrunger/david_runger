import { createPinia } from 'pinia';

import Home from '@/home/Home.vue';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(Home);
const pinia = createPinia();
app.use(pinia);
