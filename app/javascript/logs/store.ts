import { defineStore } from 'pinia';
import { last, sortBy } from 'lodash-es';
import Toastify from 'toastify-js';
import * as RoutesType from '@/rails_assets/routes';
import { kyApi } from '@/shared/ky';
import { getById } from '@/shared/store_helpers';
import { assert } from '@/shared/helpers';
import { Bootstrap, Log, LogEntry, LogEntryDataValue, LogShare } from './types';

declare const Routes: typeof RoutesType;

export const useLogsStore = defineStore('logs', {
  state: () => ({
    postingLog: false,
    ...(window.davidrunger.bootstrap as Bootstrap),
  }),

  actions: {
    addLogEntry({ logId, newLogEntry }: { logId: number, newLogEntry: LogEntry }) {
      const log = this.logById({ logId });
      const existingLogEntry = log.log_entries.find(logEntry => logEntry.id === newLogEntry.id);
      if (existingLogEntry) return;

      log.log_entries.push(newLogEntry);
    },

    async addLogShare(
      { logId, newLogShareEmail }: {
        logId: number,
        newLogShareEmail: string,
    }) {
      const payload = {
        log_share: {
          log_id: logId,
          email: newLogShareEmail,
        },
      };

      const logShareData =
        await kyApi.post(
          Routes.api_log_shares_path(),
          { json: payload },
        ).json() as LogShare;

      const log = this.logById({ logId });
      log.log_shares.push(logShareData);
    },

    async createLog(
      { log }: {
        log: {
          data_label: string,
          data_type: string,
          description: string,
          name: string,
        }
    }) {
      this.postingLog = true;

      const logData =
        await kyApi.post(
          Routes.api_logs_path(),
          { json: { log } },
        ).json() as Log;

      this.postingLog = false;
      this.logs = this.logs.concat(logData);
      return logData;
    },

    async createLogEntry(
      { logId, newLogEntryCreatedAt, newLogEntryData, newLogEntryNote }: {
        logId: number
        newLogEntryCreatedAt: null | string
        newLogEntryData: LogEntryDataValue
        newLogEntryNote: null | string
    }) {
      const payload = {
        log_entry: {
          created_at: newLogEntryCreatedAt,
          data: newLogEntryData,
          log_id: logId,
          note: newLogEntryNote,
        },
      };

      const data =
        await kyApi.post(
          Routes.api_log_entries_path(),
          { json: payload },
        ).json() as LogEntry;

      this.addLogEntry({ logId, newLogEntry: data });
    },

    async deleteLastLogEntry({ log }: { log: Log }) {
      const lastLogEntry = assert(last(sortBy(log.log_entries, 'created_at')));
      await kyApi.delete(
        Routes.api_log_entry_path({ id: lastLogEntry.id }, { log_id: log.id }),
      );
      this.deleteLogEntry({ log, logEntry: lastLogEntry });
    },

    async deleteLog({ log: logToDelete }: { log: Log }) {
      await kyApi.delete(Routes.api_log_path({ id: logToDelete.id }));
      Toastify({
        text: `Deleted "${logToDelete.name}" log.`,
        position: 'center',
        duration: 1800,
      }).showToast();
      this.router.push({ name: 'logs-index' });
      // we need to wait a tick so we don't remove the log while still on the log show page
      setTimeout(() => {
        this.logs = this.logs.filter(log => log.id !== logToDelete.id);
      });
    },

    deleteLogEntry(
      { log, logEntry: logEntryToDelete }: {
        log: Log,
        logEntry: LogEntry,
    }) {
      log.log_entries = log.log_entries.filter(logEntry => logEntry !== logEntryToDelete);
    },

    async deleteLogShare({ log, logShareId }: { log: Log, logShareId: number }) {
      await kyApi.delete(Routes.api_log_share_path({ id: logShareId }));
      log.log_shares = log.log_shares.filter(logShare => logShare.id !== logShareId);
    },

    async fetchAllLogEntries() {
      const data = await kyApi.get(Routes.api_log_entries_path()).json() as Array<LogEntry>;
      const entriesByLogId: { [key:string]: Array<LogEntry> } = {};
      for (const logEntry of data) {
        const { log_id: logId } = logEntry;
        entriesByLogId[logId] = entriesByLogId[logId] || [];
        entriesByLogId[logId].push(logEntry);
      }

      for (const logId of Object.keys(entriesByLogId)) {
        const logEntries = entriesByLogId[logId];
        this.setLogEntries({
          log: this.logById({ logId: parseInt(logId, 10) }),
          logEntries,
        });
      }
    },

    async fetchLogEntries({ logId }: { logId: number }) {
      const data =
        await kyApi.
          get(Routes.api_log_entries_path({ log_id: logId })).
          json() as Array<LogEntry>;

      this.setLogEntries({
        log: this.logById({ logId }),
        logEntries: data,
      });
    },

    setLogEntries(
      { log, logEntries }: {
        log: Log,
        logEntries: Array<LogEntry>,
    }) {
      log.log_entries = sortBy(logEntries, 'created_at');
    },

    async updateLog(
      { logId, updatedLogParams }: {
        logId: number,
        updatedLogParams: {
          publicly_viewable?: boolean,
          reminder_time_in_seconds?: number | null,
        },
    }) {
      const payload = { log: updatedLogParams };

      const updatedLogData =
        await kyApi.patch(
          Routes.api_log_path(logId),
          { json: payload },
        ).json();

      const log = this.logById({ logId });
      Object.assign(log, updatedLogData);
    },

    async updateLogEntry(
      { logEntryId, updatedLogEntryParams }: {
        logEntryId: number,
        updatedLogEntryParams: {
          data: LogEntryDataValue,
        },
    }) {
      const payload = {
        log_entry: updatedLogEntryParams,
      };

      const updatedLogEntryData =
        await kyApi.patch(
          Routes.api_log_entry_path(logEntryId),
          { json: payload },
        ).json() as LogEntry;

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
    },
  },

  getters: {
    isOwnLog(): boolean {
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
      return ({ logId }: { logId: number }): Log => getById(this.logs, logId);
    },

    selectedLog(): Log | undefined {
      const { slug } = this.router.currentRoute.value.params;
      return this.logs.find(log => log.slug === slug);
    },

    unsafeSelectedLog(): Log {
      const { slug } = this.router.currentRoute.value.params;
      return assert(this.logs.find(log => log.slug === slug));
    },
  },
});
