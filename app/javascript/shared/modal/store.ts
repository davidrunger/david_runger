import { defineStore } from 'pinia';

export const useModalStore = defineStore('modal', {
  state: () => ({
    modalsShowing: [] as Array<string>,
  }),

  actions: {
    hideModal({ modalName }: { modalName: string }) {
      this.modalsShowing = this.modalsShowing.filter(
        (showingModal) => showingModal !== modalName,
      );
    },

    hideTopModal() {
      this.modalsShowing = this.modalsShowing.slice(0, -1); // all but the last element
    },

    showModal({ modalName }: { modalName: string }) {
      if (this.modalsShowing.indexOf(modalName) === -1) {
        this.modalsShowing.push(modalName);
      }
    },
  },

  getters: {
    showingModal() {
      return ({ modalName }: { modalName: string }) =>
        this.modalsShowing.indexOf(modalName) !== -1;
    },
  },
});
