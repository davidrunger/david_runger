import { createPinia } from 'pinia';

import Comments from '@/comments/Comments.vue';
import { renderApp } from '@/shared/customized_vue';

const commentsTargetSelector = '#comments';

if (document.querySelector(commentsTargetSelector)) {
  const app = renderApp(Comments, commentsTargetSelector);

  const pinia = createPinia();
  app.use(pinia);
}
