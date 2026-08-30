declare global {
  interface Window {
    davidrunger: {
      bootstrap: object;
      connectedToCheckInsChannel?: boolean;
      connectedToLogEntriesChannel?: boolean;
      env: 'development' | 'test' | 'production';
    };
  }
}

export {};
