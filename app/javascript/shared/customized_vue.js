import axios from 'axios';
// don't (explicitly) load  element-ui button.css, because it's included in dropdown.css
import 'element-ui/lib/theme-chalk/base.css';
import 'element-ui/lib/theme-chalk/button.css';
import 'element-ui/lib/theme-chalk/card.css';
import 'element-ui/lib/theme-chalk/checkbox.css';
import 'element-ui/lib/theme-chalk/dropdown-item.css';
import 'element-ui/lib/theme-chalk/icon.css';
import 'element-ui/lib/theme-chalk/input.css';
import 'element-ui/lib/theme-chalk/menu.css';
import 'element-ui/lib/theme-chalk/menu-item.css';
import 'element-ui/lib/theme-chalk/option.css';
import 'element-ui/lib/theme-chalk/select.css';
import 'element-ui/lib/theme-chalk/submenu.css';
import 'element-ui/lib/theme-chalk/switch.css';
import 'element-ui/lib/theme-chalk/tag.css';
import {
  Button,
  Card,
  Checkbox,
  Collapse,
  CollapseItem,
  Icon,
  Input,
  Menu,
  MenuItem,
  Option,
  Select,
  Submenu,
  Switch,
  Tag,
} from 'element-ui';
import Vue from 'vue';
import { Drag, Drop } from 'vue-drag-drop';
import VueForm from 'vue-form';
import VueRouter from 'vue-router';
import Vuex from 'vuex';
import whenDomReady from 'when-dom-ready';

import Modal from 'components/modal.vue';
import 'shared/common';
import titleMixin from 'lib/mixins/title_mixin';

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
  console.error(error); // eslint-disable-line no-console
};

Vue.use(Vuex);
Vue.use(VueForm);
Vue.use(VueRouter);

Vue.mixin(titleMixin);

Vue.use(Button);
Vue.use(Card);
Vue.use(Checkbox);
Vue.use(Collapse);
Vue.use(CollapseItem);
Vue.use(Icon);
Vue.use(Input);
Vue.use(Menu);
Vue.use(MenuItem);
Vue.use(Option);
Vue.use(Select);
Vue.use(Submenu);
Vue.use(Switch);
Vue.use(Tag);

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
