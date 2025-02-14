import { createPinia } from 'pinia';
import Toast from 'vue-toastification';

import Modal from '@/components/Modal.vue';
import Groceries from '@/groceries/Groceries.vue';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(Groceries);

const pinia = createPinia();
app.use(pinia);

app.component('Modal', Modal);

app.use(Toast);
