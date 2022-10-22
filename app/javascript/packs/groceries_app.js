import { autoAnimatePlugin } from '@formkit/auto-animate/vue';
import { createPinia } from 'pinia';

import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import { useElementPlus } from '@/shared/element_plus';
import Modal from '@/components/modal.vue';
import Groceries from '@/groceries/groceries.vue';

const app = renderApp(Groceries);
const pinia = createPinia();
app.use(pinia);
app.component('Modal', Modal);
useKy(app);
useElementPlus(app);
app.use(autoAnimatePlugin);
