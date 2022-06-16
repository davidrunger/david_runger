import { createStore } from 'vuex';
import { sync } from 'vuex-router-sync';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import LogApp from '@/logs/logs.vue';
import storeDefinition from '@/logs/store';
import router from '@/logs/router';

const app = renderApp(LogApp, {
  router,
  storeDefinition,
});

app.component('Modal', Modal);
useKy(app);
useElementPlus(app);

const store = createStore({
  ...storeDefinition,
});
app.use(store);

app.use(router);

sync(store, router);
