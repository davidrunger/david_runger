import Vuex from 'vuex';

import * as ModalVuex from 'shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,
};

const actions = {};

const getters = {
  ...ModalVuex.getters,
};

function initialState(bootstrap) {
  return {
    ...bootstrap,
    ...ModalVuex.state,
  };
}

// eslint-disable-next-line import/prefer-default-export
export function workoutVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: initialState(bootstrap),
    actions,
    getters,
    mutations,
  });
}

export default workoutVuexStoreFactory(window.davidrunger.bootstrap);
