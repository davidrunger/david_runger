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
export function logVuexStoreFactory(bootstrap) {
  return new Vuex.Store({
    state: {
      ...ModalVuex.state,
      currentUser: bootstrap.current_user,
      logs: bootstrap.logs,
    },
    actions,
    getters,
    mutations,
  });
}
