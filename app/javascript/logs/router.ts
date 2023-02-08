import { createRouter, createWebHistory } from 'vue-router';

import { emit } from '@/lib/event_bus';
import Log from './components/log.vue';
import LogsIndex from './components/logs_index.vue';

const routes = [
  { path: '/logs', name: 'logs-index', component: LogsIndex },
  { path: '/logs/:slug', name: 'log', component: Log },
  { path: '/users/:user_id/logs/:slug', name: 'shared_log', component: Log },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  emit('logs:route-changed');
  next();
});

export default router;
