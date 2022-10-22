import { defineStore } from 'pinia';

const state = () => ({
  modalsShowing: [],
});

const actions = {
  hideModal({ modalName }) {
    this.modalsShowing = this.modalsShowing.filter(showingModal => showingModal !== modalName);
  },

  hideTopModal() {
    this.modalsShowing = this.modalsShowing.slice(0, -1); // all but the last element
  },

  showModal({ modalName }) {
    if (this.modalsShowing.indexOf(modalName) === -1) {
      this.modalsShowing.push(modalName);
    }
  },
};

const getters = {
  showingModal() {
    return ({ modalName }) => this.modalsShowing.indexOf(modalName) !== -1;
  },
};

export const useModalStore = defineStore('modal', {
  state,
  actions,
  getters,
});
