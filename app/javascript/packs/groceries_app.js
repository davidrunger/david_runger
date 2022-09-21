import { createStore } from 'vuex';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';
import storeDefinition from '@/groceries/store';

const app = renderApp(Groceries);

app.component('Modal', Modal);
useKy(app);
useElementPlus(app);

const store = createStore({
  ...storeDefinition,
});
app.use(store);
