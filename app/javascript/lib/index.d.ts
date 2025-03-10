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
  }
}

export {};
