import { createPinia } from 'pinia';
import Toast from 'vue-toastification';

import Modal from '@/components/Modal.vue';
import Groceries from '@/groceries/Groceries.vue';
import { renderApp } from '@/shared/customized_vue';
import { useElementPlus } from '@/shared/element_plus';

const app = renderApp(Groceries);

const pinia = createPinia();
app.use(pinia);

app.component('Modal', Modal);

useElementPlus(app);

app.use(Toast);
