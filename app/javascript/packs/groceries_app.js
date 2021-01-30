import { renderApp } from 'shared/customized_vue';
import { createStore, createLogger } from 'vuex';
import { useElementPlus } from 'shared/element_plus';
import Groceries from 'groceries/groceries.vue';
import storeDefinition from 'groceries/store';

const app = renderApp(Groceries, { storeDefinition });

useElementPlus(app);

const store = createStore({
  ...storeDefinition,
  // log Vuex updates to console since Vue Chrome extension doesn't yet support Vuex in Vue 3
  plugins: (process.env.NODE_ENV === 'development') ? [createLogger()] : [],
});
app.use(store);
