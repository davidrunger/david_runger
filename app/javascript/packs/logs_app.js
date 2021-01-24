import { renderApp } from 'shared/customized_vue';
import LogApp from 'logs/logs.vue';
import storeDefinition from 'logs/store';
import router from 'logs/router';

renderApp(LogApp, {
  router,
  storeDefinition,
});
