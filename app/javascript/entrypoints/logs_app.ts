import { createPinia } from 'pinia';
import { markRaw } from 'vue';

import LogApp from '@/logs/Logs.vue';
import router from '@/logs/router';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(LogApp);

const pinia = createPinia();
pinia.use(({ store }) => {
  store.router = markRaw(router);
});
app.use(pinia);

app.use(router);
