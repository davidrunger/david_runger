import axios from 'axios';
// don't (explicitly) load  element-ui button.css, because it's included in dropdown.css
import 'element-ui/lib/theme-chalk/base.css';
import 'element-ui/lib/theme-chalk/button.css';
import 'element-ui/lib/theme-chalk/card.css';
import 'element-ui/lib/theme-chalk/dropdown-item.css';
import 'element-ui/lib/theme-chalk/icon.css';
import 'element-ui/lib/theme-chalk/input.css';
import 'element-ui/lib/theme-chalk/menu.css';
import 'element-ui/lib/theme-chalk/menu-item.css';
import 'element-ui/lib/theme-chalk/option.css';
import 'element-ui/lib/theme-chalk/select.css';
import 'element-ui/lib/theme-chalk/submenu.css';
import 'element-ui/lib/theme-chalk/table.css';
import 'element-ui/lib/theme-chalk/table-column.css';
import {
  Button,
  Card,
  Collapse,
  CollapseItem,
  Icon,
  Input,
  Menu,
  MenuItem,
  Option,
  Select,
  Submenu,
  Table,
  TableColumn,
} from 'element-ui';
import Vue from 'vue';
import { Drag, Drop } from 'vue-drag-drop';
import VueForm from 'vue-form';
import Vuex from 'vuex';
import whenDomReady from 'when-dom-ready';

import Modal from 'components/modal.vue';
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
Vue.config.devtools = window.davidrunger && (window.davidrunger.env === 'development');

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
Vue.use(Collapse);
Vue.use(CollapseItem);
Vue.use(Icon);
Vue.use(Input);
Vue.use(Menu);
Vue.use(MenuItem);
Vue.use(Option);
Vue.use(Select);
Vue.use(Submenu);
Vue.use(Table);
Vue.use(TableColumn);

Vue.component('Modal', Modal);
Vue.component('Drag', Drag);
Vue.component('Drop', Drop);

export default Vue;

export function renderApp(vueApp, options = {}) {
  const _renderApp = () => {
    document.body.appendChild(document.createElement('replaced-container'));
    new Vue({ render: h => h(vueApp), ...options }).$mount('replaced-container');
  };

  whenDomReady(() => {
    // to prevent FOUC in development, pause briefly (to parse CSS source maps) before rendering
    if (window.davidrunger.env === 'development') {
      setTimeout(_renderApp, 150);
    } else {
      _renderApp();
    }
  });
}
