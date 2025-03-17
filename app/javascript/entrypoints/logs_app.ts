import { createPinia } from 'pinia';
import { markRaw } from 'vue';
import Toast from 'vue-toastification';

import { renderApp } from '@/lib/customized_vue';
import LogApp from '@/logs/Logs.vue';
import router from '@/logs/router';

const app = renderApp(LogApp);

const pinia = createPinia();
pinia.use(({ store }) => {
  store.router = markRaw(router);
});
app.use(pinia);

app.use(router);

app.use(Toast);
