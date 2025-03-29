declare global {
  interface Window {
    davidrunger: {
      bootstrap: object;
      connectedToLogEntriesChannel?: boolean;
      env: 'development' | 'test' | 'production';
      modalKeydownListenerRegistered: boolean;
    };
  }
}

export {};
