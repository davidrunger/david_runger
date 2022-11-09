import { autoAnimatePlugin } from '@formkit/auto-animate/vue';
import { createPinia } from 'pinia';
import { markRaw } from 'vue';

import { renderApp } from '@/shared/customized_vue';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import LogApp from '@/logs/logs.vue';
import router from '@/logs/router';

const app = renderApp(LogApp);
const pinia = createPinia();
pinia.use(({ store }) => {
  store.router = markRaw(router);
});
app.use(pinia);
app.component('Modal', Modal);
useElementPlus(app);
app.use(router);
app.use(autoAnimatePlugin);
