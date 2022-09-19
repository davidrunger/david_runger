import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import CheckInRatings from '@/check_in_ratings/app.vue';
import { ElPopover } from 'element-plus';

const app = renderApp(CheckInRatings, '#check_in_ratings_app');

app.use(ElPopover);

useKy(app);
