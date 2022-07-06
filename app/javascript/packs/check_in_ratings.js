import { renderApp } from '@/shared/customized_vue';
import { useKy } from '@/shared/ky';
import CheckInRatings from '@/check_in_ratings/app.vue';

const app = renderApp(CheckInRatings, '#check_in_ratings_app');
useKy(app);
