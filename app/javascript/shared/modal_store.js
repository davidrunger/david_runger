export const mutations = {
  hideModal(state, { modalName }) {
    state.modalsShowing = state.modalsShowing.filter(showingModal => showingModal !== modalName);
  },

  hideTopModal(state) {
    state.modalsShowing = state.modalsShowing.slice(0, -1); // all but the last element
  },

  showModal(state, { modalName }) {
    if (state.modalsShowing.indexOf(modalName) === -1) {
      state.modalsShowing.push(modalName);
    }
  },
};

export const getters = {
  showingModal(state) {
    return ({ modalName }) => {
      return state.modalsShowing.indexOf(modalName) !== -1;
    };
  },
};

export const state = {
  modalsShowing: [],
};
