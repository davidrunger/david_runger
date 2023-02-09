import { Component, ComputedOptions, createApp, MethodOptions } from 'vue';
import whenDomReady from 'when-dom-ready';

import { isMobileDevice } from '@/lib/is_mobile_device';
import * as Routes from '@/rails_assets/routes';
import titleMixin from '@/lib/mixins/title_mixin';

window.Routes = Routes;

export function renderApp(
  vueApp: Component<unknown, unknown, unknown, ComputedOptions, MethodOptions>,
  domTargetSelector = '#container',
) {
  const app = createApp(vueApp);

  app.config.globalProperties.$routes = Routes;
  app.config.globalProperties.$bootstrap = window.davidrunger ? window.davidrunger.bootstrap : {};

  const mobileDeviceBoolean = isMobileDevice();
  app.config.globalProperties.$is_mobile_device = mobileDeviceBoolean;
  app.provide('isMobileDevice', mobileDeviceBoolean);

  app.mixin(titleMixin);

  const _renderApp = () => {
    app.mount(domTargetSelector);
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
