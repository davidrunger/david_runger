import { defineStore } from 'pinia';
import { last, sortBy } from 'lodash-es';
import Toastify from 'toastify-js';
import { kyApi } from '@/shared/ky';

const state = () => ({
  ...window.davidrunger.bootstrap,
  postingLog: false,
});

const actions = {
  addLogEntry({ logId, newLogEntry }) {
    const log = this.logById({ logId });
    const existingLogEntry = log.log_entries.find(logEntry => logEntry.id === newLogEntry.id);
    if (existingLogEntry) return;

    log.log_entries.push(newLogEntry);
  },

  addLogShare({ logId, newLogShareEmail }) {
    const payload = {
      log_share: {
        log_id: logId,
        email: newLogShareEmail,
      },
    };

    kyApi.post(Routes.api_log_shares_path(), { json: payload }).json().then(logShareData => {
      const log = this.logById({ logId });
      log.log_shares.push(logShareData);
    });
  },

  createLog({ log }) {
    this.postingLog = true;

    return kyApi.
      post(Routes.api_logs_path(), { json: { log } }).json().
      then((logData) => {
        this.postingLog = false;
        this.logs = this.logs.concat(logData);
        return logData;
      });
  },

  createLogEntry({ logId, newLogEntryCreatedAt, newLogEntryData, newLogEntryNote }) {
    const payload = {
      log_entry: {
        created_at: newLogEntryCreatedAt,
        data: newLogEntryData,
        log_id: logId,
        note: newLogEntryNote,
      },
    };

    return kyApi.post(Routes.api_log_entries_path(), { json: payload }).json().then(data => {
      this.addLogEntry({ logId, newLogEntry: data });
    });
  },

  deleteLastLogEntry({ log }) {
    const lastLogEntry = last(sortBy(log.log_entries, 'created_at'));
    kyApi.
      delete(Routes.api_log_entry_path({
        id: lastLogEntry.id,
        log_id: log.id,
        _options: {}, // providing `_options` seems to be necessary to put query params in the path
      })).
      then(() => { this.deleteLogEntry({ log, logEntry: lastLogEntry }); });
  },

  deleteLog({ log: logToDelete }) {
    kyApi.delete(Routes.api_log_path({ id: logToDelete.id })).
      then(() => {
        this.logs = this.logs.filter(log => log.id !== logToDelete.id);
        Toastify({
          text: `Deleted "${logToDelete.name}" log.`,
          className: 'success',
          position: 'center',
          duration: 1800,
        }).showToast();
        this.router.push({ name: 'logs-index' });
      });
  },

  deleteLogEntry({ log, logEntry: logEntryToDelete }) {
    log.log_entries = log.log_entries.filter(logEntry => logEntry !== logEntryToDelete);
  },

  deleteLogShare({ log, logShareId }) {
    kyApi.delete(Routes.api_log_share_path({ id: logShareId })).
      then(() => {
        log.log_shares = log.log_shares.filter(logShare => logShare.id !== logShareId);
      });
  },

  fetchAllLogEntries() {
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
          this.setLogEntries({
            log: this.logById({ logId: parseInt(logId, 10) }),
            logEntries,
          });
        });
      });
  },

  fetchLogEntries({ logId }) {
    kyApi.
      get(Routes.api_log_entries_path({ log_id: logId })).
      json().
      then(data => {
        this.setLogEntries({
          log: this.logById({ logId }),
          logEntries: data,
        });
      });
  },

  setLogEntries({ log, logEntries }) {
    log.log_entries = sortBy(logEntries, 'created_at');
  },

  updateLog({ logId, updatedLogParams }) {
    const payload = { log: updatedLogParams };

    return (
      kyApi.
        patch(Routes.api_log_path(logId), { json: payload }).
        json().
        then(updatedLogData => {
          const log = this.logById({ logId });
          Object.assign(log, updatedLogData);
        })
    );
  },

  updateLogEntry({ logEntryId, updatedLogEntryParams }) {
    const payload = {
      log_entry: updatedLogEntryParams,
    };

    return (
      kyApi.
        patch(Routes.api_log_entry_path(logEntryId), { json: payload }).
        json().
        then(updatedLogEntryData => {
          const logId = updatedLogEntryData.log_id;
          const log = this.logById({ logId });
          log.log_entries =
            log.log_entries.map(logEntry => {
              if (logEntry.id === logEntryId) {
                return updatedLogEntryData;
              } else {
                return logEntry;
              }
            });
        })
    );
  },
};

const getters = {
  // eslint-disable-next-line no-shadow
  isOwnLog() {
    if (!this.selectedLog) return false;

    return this.selectedLog.user.id === this.current_user.id;
  },

  // eslint-disable-next-line no-shadow
  isSharedLog() {
    const logIsPresent = !!this.selectedLog;
    const isNotOwnLog = !this.isOwnLog;
    return logIsPresent && isNotOwnLog;
  },

  logById() {
    return ({ logId }) => this.logs.find(log => log.id === logId);
  },

  logByName() {
    return ({ logName }) => this.logs.find(log => log.name === logName);
  },

  selectedLog() {
    const { slug } = this.router.currentRoute.value.params;
    return this.logs.find(log => log.slug === slug);
  },
};

export const useLogsStore = defineStore('logs', {
  state,
  actions,
  getters,
});
