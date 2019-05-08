import { sync } from 'vuex-router-sync';

import { renderApp } from 'shared/customized_vue';
import LogApp from 'log/logs.vue';
import { logVuexStoreFactory } from 'log/store';
import router from 'log/router';

const store = logVuexStoreFactory(window.davidrunger.bootstrap);
sync(store, router);

renderApp(LogApp, {
  router,
  store,
});
