import axios from 'axios';
import Vue from 'vue';
import Vuex from 'vuex';
import _ from 'lodash';
import Toastify from 'toastify-js';

import * as ModalVuex from 'shared/modal_store';
import router from 'logs/router';

const mutations = {
  ...ModalVuex.mutations,

  addLogEntry(_state, { log, logEntry }) {
    log.log_entries.push(logEntry);
  },

  addLogShare(_state, { log, logShare }) {
    log.log_shares.push(logShare);
  },

  deleteLog(state, { log: logToDelete }) {
    state.logs = state.logs.filter(log => log.id !== logToDelete.id);
    Toastify({
      text: `Deleted "${logToDelete.name}" log.`,
      className: 'success',
      position: 'center',
      duration: 1800,
    }).showToast();
    router.push({ name: 'logs-index' });
  },

  deleteLogEntry(_state, { log, logEntry: logEntryToDelete }) {
    log.log_entries = log.log_entries.filter(logEntry => logEntry !== logEntryToDelete);
  },

  deleteLogShare(_state, { log, logShareId }) {
    log.log_shares = log.log_shares.filter(logShare => logShare.id !== logShareId);
  },

  setLogEntries(state, { log, logEntries }) {
    Vue.set(log, 'log_entries', logEntries);
  },

  updateLogEntry(_state, { log, logEntryId, updatedLogEntryData }) {
    log.log_entries =
      log.log_entries.map(logEntry => {
        if (logEntry.id === logEntryId) {
          return updatedLogEntryData;
        } else {
          return logEntry;
        }
      });
  },
};

const actions = {
  addLogEntry({ commit, getters }, { logId, newLogEntryData, newLogEntryNote }) {
    const payload = {
      log_entry: {
        data: newLogEntryData,
        log_id: logId,
        note: newLogEntryNote,
      },
    };

    axios.post(Routes.api_log_entries_path(), payload).then(({ data }) => {
      const log = getters.logById({ logId });
      commit('addLogEntry', { log, logEntry: data });
    });
  },

  addLogShare({ commit, getters }, { logId, newLogShareEmail }) {
    const payload = {
      log_share: {
        log_id: logId,
        email: newLogShareEmail,
      },
    };

    axios.post(Routes.api_log_shares_path(), payload).then(({ data }) => {
      const log = getters.logById({ logId });
      commit('addLogShare', { log, logShare: data });
    });
  },

  deleteLastLogEntry({ commit }, { log }) {
    const lastLogEntry = _(log.log_entries).sortBy('created_at').last();
    axios.
      delete(Routes.api_log_entry_path({
        id: lastLogEntry.id,
        log_id: log.id,
        _options: {}, // providing `_options` seems to be necessary to put query params in the path
      })).
      then(() => { commit('deleteLogEntry', { log, logEntry: lastLogEntry }); });
  },

  deleteLog({ commit }, { log }) {
    axios.delete(Routes.api_log_path({ id: log.id })).
      then(() => { commit('deleteLog', { log }); });
  },

  deleteLogShare({ commit }, { log, logShareId }) {
    axios.delete(Routes.api_log_share_path({ id: logShareId })).
      then(() => { commit('deleteLogShare', { log, logShareId }); });
  },

  fetchAllLogEntries({ commit, getters }) {
    axios.
      get(Routes.api_log_entries_path()).
      then(({ data }) => {
        const entriesByLogId = {};
        data.forEach(logEntry => {
          const { log_id: logId } = logEntry;
          entriesByLogId[logId] = entriesByLogId[logId] || [];
          entriesByLogId[logId].push(logEntry);
        });

        Object.keys(entriesByLogId).forEach(logId => {
          const logEntries = entriesByLogId[logId];
          commit(
            'setLogEntries',
            {
              log: getters.logById({ logId: parseInt(logId, 10) }),
              logEntries,
            },
          );
        });
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

  updateLogEntry({ commit, getters }, { logEntryId, updatedLogEntryParams }) {
    const payload = {
      log_entry: updatedLogEntryParams,
    };

    return (
      axios.
        patch(Routes.api_log_entry_path(logEntryId), payload).
        then(({ data }) => {
          const logId = data.log_id;
          const log = getters.logById({ logId });
          commit(
            'updateLogEntry',
            { log, logEntryId, updatedLogEntryData: data },
          );
        })
    );
  },
};

const getters = {
  ...ModalVuex.getters,

  // eslint-disable-next-line no-shadow
  isOwnLog(state, getters) {
    if (!getters.selectedLog) return false;

    return getters.selectedLog.user.id === state.currentUser.id;
  },

  logById(state) {
    return ({ logId }) => state.logs.find(log => log.id === logId);
  },

  logByName(state) {
    return ({ logName }) => state.logs.find(log => log.name === logName);
  },

  selectedLog(state) {
    const { slug } = state.route.params;
    return state.logs.find(log => log.slug === slug);
  },
};

// eslint-disable-next-line import/prefer-default-export
export function logVuexStoreFactory(bootstrap, options = {}) {
  const state = {
    ...ModalVuex.state,
    currentUser: bootstrap.current_user,
    logs: bootstrap.logs,
  };

  let gettersMaybeIncludingStubs = getters;
  if (window.davidrunger.env === 'test') {
    gettersMaybeIncludingStubs = {
      ...getters,
      ...options.mockedGetters,
    };
  }

  return new Vuex.Store({
    state,
    actions,
    getters: gettersMaybeIncludingStubs,
    mutations,
  });
}
