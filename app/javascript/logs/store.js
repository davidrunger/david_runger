import { last, sortBy } from 'lodash-es';
import Toastify from 'toastify-js';
import { kyApi } from '@/shared/ky';

import {
  getters as modalGetters,
  mutations as modalMutations,
  state as modalState,
} from '@/shared/modal_store';
import router from './router';

const mutations = {
  ...modalMutations,

  addLogEntry(_state, { log, newLogEntry }) {
    const existingLogEntry = log.log_entries.find(logEntry => logEntry.id === newLogEntry.id);
    if (existingLogEntry) return;

    log.log_entries.push(newLogEntry);
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
    log.log_entries = sortBy(logEntries, 'created_at');
  },

  updateLog(_state, { log, updatedLogData }) {
    Object.assign(log, updatedLogData);
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
  addLogEntry({ commit, getters }, { logId, newLogEntry }) {
    const log = getters.logById({ logId });
    commit('addLogEntry', { log, newLogEntry });
  },

  createLogEntry({ dispatch }, { logId, newLogEntryCreatedAt, newLogEntryData, newLogEntryNote }) {
    const payload = {
      log_entry: {
        created_at: newLogEntryCreatedAt,
        data: newLogEntryData,
        log_id: logId,
        note: newLogEntryNote,
      },
    };

    kyApi.post(Routes.api_log_entries_path(), { json: payload }).json().then(data => {
      dispatch('addLogEntry', { logId, newLogEntry: data });
    });
  },

  addLogShare({ commit, getters }, { logId, newLogShareEmail }) {
    const payload = {
      log_share: {
        log_id: logId,
        email: newLogShareEmail,
      },
    };

    kyApi.post(Routes.api_log_shares_path(), { json: payload }).json().then(data => {
      const log = getters.logById({ logId });
      commit('addLogShare', { log, logShare: data });
    });
  },

  deleteLastLogEntry({ commit }, { log }) {
    const lastLogEntry = last(sortBy(log.log_entries, 'created_at'));
    kyApi.
      delete(Routes.api_log_entry_path({
        id: lastLogEntry.id,
        log_id: log.id,
        _options: {}, // providing `_options` seems to be necessary to put query params in the path
      })).
      then(() => { commit('deleteLogEntry', { log, logEntry: lastLogEntry }); });
  },

  deleteLog({ commit }, { log }) {
    kyApi.delete(Routes.api_log_path({ id: log.id })).
      then(() => { commit('deleteLog', { log }); });
  },

  deleteLogShare({ commit }, { log, logShareId }) {
    kyApi.delete(Routes.api_log_share_path({ id: logShareId })).
      then(() => { commit('deleteLogShare', { log, logShareId }); });
  },

  fetchAllLogEntries({ commit, getters }) {
    kyApi.
      get(Routes.api_log_entries_path()).
      json().
      then(data => {
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
    kyApi.
      get(Routes.api_log_entries_path({ log_id: logId })).
      json().
      then(data => {
        commit(
          'setLogEntries',
          {
            log: getters.logById({ logId }),
            logEntries: data,
          },
        );
      });
  },

  updateLog({ commit, getters }, { logId, updatedLogParams }) {
    const payload = { log: updatedLogParams };

    return (
      kyApi.
        patch(Routes.api_log_path(logId), { json: payload }).
        json().
        then(data => {
          const log = getters.logById({ logId });
          commit(
            'updateLog',
            { log, updatedLogData: data },
          );
        })
    );
  },

  updateLogEntry({ commit, getters }, { logEntryId, updatedLogEntryParams }) {
    const payload = {
      log_entry: updatedLogEntryParams,
    };

    return (
      kyApi.
        patch(Routes.api_log_entry_path(logEntryId), { json: payload }).
        json().
        then(data => {
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
  ...modalGetters,

  // eslint-disable-next-line no-shadow
  isOwnLog(state, getters) {
    if (!getters.selectedLog) return false;

    return getters.selectedLog.user.id === state.current_user.id;
  },

  // eslint-disable-next-line no-shadow
  isSharedLog(state, getters) {
    const logIsPresent = !!getters.selectedLog;
    const isNotOwnLog = !getters.isOwnLog;
    return logIsPresent && isNotOwnLog;
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

const state = {
  ...window.davidrunger.bootstrap,
  ...modalState,
};

export default {
  state,
  actions,
  getters,
  mutations,
};
