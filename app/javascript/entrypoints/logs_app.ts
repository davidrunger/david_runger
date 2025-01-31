import { createPinia } from 'pinia';
import { markRaw } from 'vue';

import Modal from '@/components/Modal.vue';
import LogApp from '@/logs/Logs.vue';
import router from '@/logs/router';
import { renderApp } from '@/shared/customized_vue';
import { useElementPlus } from '@/shared/element_plus';

const app = renderApp(LogApp);

const pinia = createPinia();
pinia.use(({ store }) => {
  store.router = markRaw(router);
});
app.use(pinia);

app.component('Modal', Modal);

useElementPlus(app);

app.use(router);
