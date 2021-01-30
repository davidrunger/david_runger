import axios from 'axios';
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

  return app;
}
