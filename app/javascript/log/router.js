import VueRouter from 'vue-router';

import Log from 'log/components/log.vue';
import LogsIndex from 'log/components/logs_index.vue';

const routes = [
  { path: '/logs',  name: 'logs-index', component: LogsIndex },
  { path: '/logs/:slug', name: 'log', component: Log },
];

const router = new VueRouter({
  mode: 'history',
  routes,
});

export default router;
