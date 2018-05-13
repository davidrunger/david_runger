import Vuex from 'vuex';

const mutations = {};
const actions = {};
const getters = {};

// eslint-disable-next-line import/prefer-default-export
export function logVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: {
      currentUser: bootstrap.current_user,
      weightLogs: bootstrap.weight_logs,
    },
    actions,
    getters,
    mutations,
  });
}
