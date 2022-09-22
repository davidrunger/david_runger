import { createStore } from 'vuex';
import { sync } from 'vuex-router-sync';
import { autoAnimatePlugin } from '@formkit/auto-animate/vue';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import LogApp from '@/logs/logs.vue';
import storeDefinition from '@/logs/store';
import router from '@/logs/router';

const store = createStore({
  ...storeDefinition,
});

const app = renderApp(LogApp);
app.component('Modal', Modal);
useKy(app);
useElementPlus(app);
app.use(store);
app.use(router);
sync(store, router);
app.use(autoAnimatePlugin);
