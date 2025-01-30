import * as RoutesType from '@/rails_assets/routes';

declare global {
  interface Window {
    $: JQueryStatic;
    davidrunger: {
      bootstrap: object;
      connectedToLogEntriesChannel?: boolean;
      env: 'development' | 'test' | 'production';
      modalKeydownListenerRegistered: boolean;
    };
    jQuery: JQueryStatic;
    Routes: typeof RoutesType;
  }
}

export {};
