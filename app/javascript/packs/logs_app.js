import { sync } from 'vuex-router-sync';

import { renderApp } from 'shared/customized_vue';
import LogApp from 'logs/logs.vue';
import { logVuexStoreFactory } from 'logs/store';
import router from 'logs/router';

const store = logVuexStoreFactory(window.davidrunger.bootstrap);
sync(store, router);

renderApp(LogApp, {
  router,
  store,
});
