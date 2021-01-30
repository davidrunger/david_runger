import { createApp } from 'vue';
import whenDomReady from 'when-dom-ready';

import Modal from 'components/modal.vue';
import 'shared/common';
import titleMixin from 'lib/mixins/title_mixin';

export function renderApp(vueApp) {
  const app = createApp(vueApp);

  app.config.devtools = window.davidrunger && (window.davidrunger.env === 'development');

  app.config.globalProperties.$routes = window.Routes;
  app.config.globalProperties.bootstrap = window.davidrunger && window.davidrunger.bootstrap;

  app.mixin(titleMixin);

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
