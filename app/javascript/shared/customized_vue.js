import axios from 'axios';
// don't (explicitly) load element-plus button.css, because it's included in dropdown.css
import 'element-plus/lib/theme-chalk/base.css';
import 'element-plus/lib/theme-chalk/el-button.css';
import 'element-plus/lib/theme-chalk/el-card.css';
import 'element-plus/lib/theme-chalk/el-checkbox.css';
import 'element-plus/lib/theme-chalk/el-date-picker.css';
import 'element-plus/lib/theme-chalk/el-dropdown-item.css';
import 'element-plus/lib/theme-chalk/el-icon.css';
import 'element-plus/lib/theme-chalk/el-input.css';
import 'element-plus/lib/theme-chalk/el-menu.css';
import 'element-plus/lib/theme-chalk/el-menu-item.css';
import 'element-plus/lib/theme-chalk/el-option.css';
import 'element-plus/lib/theme-chalk/el-select.css';
import 'element-plus/lib/theme-chalk/el-submenu.css';
import 'element-plus/lib/theme-chalk/el-switch.css';
import 'element-plus/lib/theme-chalk/el-tag.css';
import {
  ElButton,
  ElCard,
  ElCheckbox,
  ElCollapse,
  ElCollapseItem,
  ElDatePicker,
  ElIcon,
  ElInput,
  ElMenu,
  ElMenuItem,
  ElOption,
  ElSelect,
  ElSubmenu,
  ElSwitch,
  ElTag,
} from 'element-plus';
import { createApp } from 'vue';
import { createStore, createLogger } from 'vuex';
import { sync } from 'vuex-router-sync';
import whenDomReady from 'when-dom-ready';

import Modal from 'components/modal.vue';
import 'shared/common';
import titleMixin from 'lib/mixins/title_mixin';

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
if (csrfMetaTag) {
  const csrfToken = csrfMetaTag.getAttribute('content');
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

export function renderApp(vueApp, { router, storeDefinition } = {}) {
  const app = createApp(vueApp);

  app.config.devtools = window.davidrunger && (window.davidrunger.env === 'development');

  app.config.globalProperties.$routes = window.Routes;
  app.config.globalProperties.bootstrap = window.davidrunger && window.davidrunger.bootstrap;
  app.config.globalProperties.$http = axios;

  app.mixin(titleMixin);

  if (router) {
    app.use(router);
  }

  if (storeDefinition) {
    const store = createStore({
      ...storeDefinition,
      // log Vuex updates to console since Vue Chrome extension doesn't yet support Vuex in Vue 3
      plugins: (process.env.NODE_ENV === 'development') ? [createLogger()] : [],
    });
    app.use(store);

    if (router) {
      sync(store, router);
    }
  }

  app.use(ElButton);
  app.use(ElCard);
  app.use(ElCheckbox);
  app.use(ElCollapse);
  app.use(ElCollapseItem);
  app.use(ElDatePicker);
  app.use(ElIcon);
  app.use(ElInput);
  app.use(ElMenu);
  app.use(ElMenuItem);
  app.use(ElOption);
  app.use(ElSelect);
  app.use(ElSubmenu);
  app.use(ElSwitch);
  app.use(ElTag);

  app.component('Modal', Modal);

  const _renderApp = () => {
    document.body.appendChild(document.createElement('replaced-container'));
    app.mount('replaced-container');
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
