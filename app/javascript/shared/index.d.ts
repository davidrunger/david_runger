declare global {
  interface Window {
    davidrunger: {
      bootstrap: object
      modalKeydownListenerRegistered: boolean
    }
  }
}

export {};
