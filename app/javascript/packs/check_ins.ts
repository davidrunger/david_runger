import { ElPopover } from 'element-plus';
import { createPinia } from 'pinia';

import CheckIns from '@/check_ins/App.vue';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(CheckIns, '#check_ins_app');
const pinia = createPinia();
app.use(pinia);
app.use(ElPopover);
