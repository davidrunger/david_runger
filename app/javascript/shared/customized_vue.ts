import { Component, ComputedOptions, createApp, MethodOptions } from 'vue';
import whenDomReady from 'when-dom-ready';

export function renderApp(
  vueApp: Component<unknown, unknown, unknown, ComputedOptions, MethodOptions>,
  domTargetSelector = '#container',
) {
  const app = createApp(vueApp);

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
