import { defineStore } from 'pinia';

const state = () => ({
  ...window.davidrunger.bootstrap,
});

export const useCheckInsStore = defineStore('check-ins', {
  state,
});
