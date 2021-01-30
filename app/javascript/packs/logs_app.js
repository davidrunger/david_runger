import { renderApp } from 'shared/customized_vue';
import { useElementPlus } from 'shared/element_plus';
import LogApp from 'logs/logs.vue';
import storeDefinition from 'logs/store';
import router from 'logs/router';

const app = renderApp(LogApp, {
  router,
  storeDefinition,
});
useElementPlus(app);
