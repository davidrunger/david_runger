import Vuex from 'vuex';

import * as ModalVuex from 'shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,

  selectLog(state, { logName }) {
    state.selectedLogName = logName;
  },
};

const actions = {
  selectLog({ commit }, { logName }) {
    commit('selectLog', { logName });
    commit('hideModal', { modalName: 'log-selector' });
  },
};

const getters = {
  ...ModalVuex.getters,

  selectedLog(state) {
    return state.logs.find(log => log.name === state.selectedLogName);
  },
};

// eslint-disable-next-line import/prefer-default-export
export function logVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: {
      ...ModalVuex.state,
      currentUser: bootstrap.current_user,
      logs: bootstrap.logs,
      selectedLogName: null,
    },
    actions,
    getters,
    mutations,
  });
}
