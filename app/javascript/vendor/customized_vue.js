import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios';
import { Drag, Drop } from 'vue-drag-drop';
import modal from '../components/modal.vue';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

// convenience to access axios via this.$http
Vue.prototype.$http = axios;

Vue.prototype.bootstrap = window.davidrunger && window.davidrunger.bootstrap;

Vue.config.productionTip = false;

Vue.use(Vuex);

Vue.component('modal', modal);
Vue.component('drag', Drag);
Vue.component('drop', Drop);

export default Vue;
