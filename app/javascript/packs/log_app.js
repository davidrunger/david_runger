import { renderApp } from 'shared/customized_vue';
import LogApp from 'log/logs.vue';
import { logVuexStoreFactory } from 'log/store';

renderApp(LogApp, { store: logVuexStoreFactory(window.davidrunger.bootstrap) });
