import { createPinia } from 'pinia';
import Toast from 'vue-toastification';

import Groceries from '@/groceries/Groceries.vue';
import { renderApp } from '@/lib/customized_vue';

const app = renderApp(Groceries);

const pinia = createPinia();
app.use(pinia);

app.use(Toast);
