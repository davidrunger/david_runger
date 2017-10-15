import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios';
import modal from '../components/modal.vue';

const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;

// convenience to access axios via this.$http
Vue.prototype.$http = axios;

Vue.prototype.bootstrap = window.davidrunger.bootstrap;

Vue.config.productionTip = false;

Vue.use(Vuex);

Vue.component('modal', modal);

export default Vue;
