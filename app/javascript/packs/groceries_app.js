import { createStore } from 'vuex';
import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { faEdit } from '@fortawesome/free-regular-svg-icons';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';
import storeDefinition from '@/groceries/store';

const app = renderApp(Groceries, { storeDefinition });

app.component('Modal', Modal);
useKy(app);
useElementPlus(app);

library.add(faEdit);
app.component('font-awesome-icon', FontAwesomeIcon);

const store = createStore({
  ...storeDefinition,
});
app.use(store);
