import axios from 'axios';
import Vue from 'vue';
import Vuex from 'vuex';

import * as ModalVuex from 'shared/modal_store';

const mutations = {
  ...ModalVuex.mutations,

  addLogEntry(_state, { log, logEntry }) {
    log.log_entries.push(logEntry);
  },

  selectLog(state, { logName }) {
    state.selectedLogName = logName;
  },

  setLogEntries(state, { log, logEntries }) {
    Vue.set(log, 'log_entries', logEntries);
  },
};

const actions = {
  addLogEntry({ commit, getters }, { logId, newLogEntryData }) {
    const payload = {
      log_entry: {
        data: newLogEntryData,
        log_id: logId,
      },
    };

    axios.post(Routes.api_log_entries_path(), payload).then(({ data }) => {
      const log = getters.logById({ logId });
      commit('addLogEntry', { log, logEntry: data });
    });
  },

  fetchLogEntries({ commit, getters }, { logId }) {
    axios.
      get(Routes.api_log_entries_path({ log_id: logId })).
      then(({ data }) => {
        commit(
          'setLogEntries',
          {
            log: getters.logById({ logId }),
            logEntries: data,
          },
        );
      });
  },

  selectLog({ commit }, { logName }) {
    commit('selectLog', { logName });
    commit('hideModal', { modalName: 'log-selector' });
  },
};

const getters = {
  ...ModalVuex.getters,

  logById(state) {
    return ({ logId }) => {
      return state.logs.find(log => log.id === logId);
    };
  },

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
