import { createPinia } from 'pinia';

import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';
import { renderApp } from '@/shared/customized_vue';
import { useElementPlus } from '@/shared/element_plus';

const app = renderApp(Groceries);
const pinia = createPinia();
app.use(pinia);
app.component('Modal', Modal);
useElementPlus(app);
