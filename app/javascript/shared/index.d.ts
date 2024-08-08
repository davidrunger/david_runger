import * as RoutesType from '@/rails_assets/routes';

declare global {
  interface Window {
    davidrunger: {
      bootstrap: object;
      connectedToLogEntriesChannel?: boolean;
      env: 'development' | 'test' | 'production';
      modalKeydownListenerRegistered: boolean;
    };
    Routes: typeof RoutesType;
  }
}

export {};
