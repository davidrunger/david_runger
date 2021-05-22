import { createApp } from 'vue';
import whenDomReady from 'when-dom-ready';

import * as Routes from '@/rails_assets/routes';
import titleMixin from '@/lib/mixins/title_mixin';

window.Routes = Routes;

export function renderApp(vueApp) {
  const app = createApp(vueApp);

  app.config.devtools = window.davidrunger && (window.davidrunger.env === 'development');

  app.config.globalProperties.$routes = Routes;
  app.config.globalProperties.bootstrap = window.davidrunger && window.davidrunger.bootstrap;

  app.mixin(titleMixin);

  const _renderApp = () => {
    app.mount('#container');
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
