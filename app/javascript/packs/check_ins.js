import { createPinia } from 'pinia';
import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import CheckIns from '@/check_ins/app.vue';
import { ElPopover } from 'element-plus';

const app = renderApp(CheckIns, '#check_ins_app');
const pinia = createPinia();
app.use(pinia);
app.use(ElPopover);
useKy(app);
