import { createPinia } from 'pinia';
import { renderApp } from '@/shared/customized_vue';
import Home from '@/home/home.vue';

const app = renderApp(Home);
const pinia = createPinia();
app.use(pinia);
