import { createStore } from 'vuex';

import { renderApp } from '@/shared/customized_vue';
import { useAxios } from '@/shared/axios';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';
import storeDefinition from '@/groceries/store';

const app = renderApp(Groceries, { storeDefinition });

app.component('Modal', Modal);
useAxios(app);
useElementPlus(app);

const store = createStore({
  ...storeDefinition,
});
app.use(store);
