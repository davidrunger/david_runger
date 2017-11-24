import Vue from 'vue';
import Vuex from 'vuex';
import {
  Button,
  Dropdown,
  DropdownMenu,
  DropdownItem,
  Input,
} from 'element-ui';
import axios from 'axios';
import { Drag, Drop } from 'vue-drag-drop';
import modal from 'components/modal.vue';
import 'shared/common';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

// convenience to access axios via this.$http
Vue.prototype.$http = axios;

Vue.prototype.bootstrap = window.davidrunger && window.davidrunger.bootstrap;

Vue.prototype.$routes = window.Routes;

Vue.config.productionTip = false;

Vue.use(Vuex);

Vue.use(Button);
Vue.use(Dropdown);
Vue.use(DropdownMenu);
Vue.use(DropdownItem);
Vue.use(Input);

Vue.component('modal', modal);
Vue.component('drag', Drag);
Vue.component('drop', Drop);

export default Vue;

export function renderApp(vueApp, options = {}) {
  const _renderApp = () => {
    document.body.appendChild(document.createElement('replaced-container'));
    new Vue({ render: h => h(vueApp), ...options }).$mount('replaced-container');
  };

  document.addEventListener('DOMContentLoaded', () => {
    // to prevent FOUC in development, pause briefly (to parse CSS source maps) before rendering
    if (window.davidrunger.env === 'development') {
      setTimeout(_renderApp, 150);
    } else {
      _renderApp();
    }
  });
}
