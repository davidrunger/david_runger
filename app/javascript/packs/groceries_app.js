import { createStore } from 'vuex';
import { autoAnimatePlugin } from '@formkit/auto-animate/vue';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';
import storeDefinition from '@/groceries/store';

const store = createStore({
  ...storeDefinition,
});

const app = renderApp(Groceries);
app.component('Modal', Modal);
useKy(app);
useElementPlus(app);
app.use(store);
app.use(autoAnimatePlugin);
