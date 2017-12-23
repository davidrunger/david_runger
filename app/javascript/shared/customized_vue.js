import axios from 'axios';
import {
  Button,
  Card,
  Dropdown,
  DropdownMenu,
  DropdownItem,
  Icon,
  Input,
} from 'element-ui';
import Vue from 'vue';
import { Drag, Drop } from 'vue-drag-drop';
import VueForm from 'vue-form';
import Vuex from 'vuex';

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
Vue.config.devtools = (window.davidrunger && (window.davidrunger.env === 'development'));

Vue.config.errorHandler = (error, _vm, info) => {
  if (window.Rollbar && window.Rollbar.error) {
    window.Rollbar.error(error, { info });
  }
  // Log the error in all environments. test is configured such that this will actually raise an
  // error and fail tests. In dev and prod, it will help with debugging.
  console.error(error); // eslint-disable-line no-console
};

Vue.use(Vuex);

Vue.use(VueForm);

Vue.use(Button);
Vue.use(Card);
Vue.use(Dropdown);
Vue.use(DropdownMenu);
Vue.use(DropdownItem);
Vue.use(Icon);
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
