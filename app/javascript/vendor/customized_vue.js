import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios';
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

export default Vue;
