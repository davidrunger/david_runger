import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex';
import axios from 'axios';

const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;

// convenience to access axios via this.$http
Vue.prototype.$http = axios;

Vue.prototype.bootstrap = window.davidrunger.bootstrap;

Vue.config.productionTip = false;

Vue.use(Vuex);

export default Vue;
