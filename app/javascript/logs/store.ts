import { last, sortBy } from 'lodash-es';
import { defineStore } from 'pinia';

import { bootstrap as untypedBootstrap } from '@/lib/bootstrap';
import { toast } from '@/lib/toasts';
import * as RoutesType from '@/rails_assets/routes';
import { assert, typesafeAssign } from '@/shared/helpers';
import { kyApi } from '@/shared/ky';
import { getById } from '@/shared/store_helpers';
import type {
  Intersection,
  LogEntry,
  LogEntryDataValue,
  LogShare,
} from '@/types';
import { LogCreateResponse } from '@/types/responses/LogCreateResponse';
import { LogEntriesIndexResponse } from '@/types/responses/LogEntriesIndexResponse';
import { LogEntryCreateResponse } from '@/types/responses/LogEntryCreateResponse';
import { LogEntryUpdateResponse } from '@/types/responses/LogEntryUpdateResponse';
import { LogShareCreateResponse } from '@/types/responses/LogShareCreateResponse';
import { LogUpdateResponse } from '@/types/responses/LogUpdateResponse';

import { Bootstrap, Log } from './types';

declare const Routes: typeof RoutesType;

const bootstrap = untypedBootstrap as Bootstrap;

export const useLogsStore = defineStore('logs', {
  state: () => ({
    ...bootstrap,
    postingLog: false,
  }),

  actions: {
    addLogEntry({
      logId,
      newLogEntry,
    }: {
      logId: number;
      newLogEntry: LogEntry;
    }) {
      const log = this.logById({ logId });
      const existingLogEntry = log.log_entries?.find(
        (logEntry) => logEntry.id === newLogEntry.id,
      );
      if (existingLogEntry) return;

      log.log_entries?.push(newLogEntry);
    },

    async addLogShare({
      logId,
      newLogShareEmail,
    }: {
      logId: number;
      newLogShareEmail: string;
    }) {
      const payload = {
        log_share: {
          log_id: logId,
          email: newLogShareEmail,
        },
      };

      const logShareData = await kyApi
        .post<
          Intersection<LogShare, LogShareCreateResponse>
        >(Routes.api_log_shares_path(), { json: payload })
        .json();

      const log = this.logById({ logId });
      log.log_shares?.push(logShareData);
    },

    async createLog({
      log,
    }: {
      log: {
        data_label: string;
        data_type: string;
        description: string;
        name: string;
      };
    }) {
      this.postingLog = true;

      const logData = await kyApi
        .post<
          Intersection<Log, LogCreateResponse>
        >(Routes.api_logs_path(), { json: { log } })
        .json();

      this.postingLog = false;
      this.logs.push(logData);
      return logData;
    },

    async createLogEntry({
      logId,
      newLogEntryCreatedAt,
      newLogEntryData,
      newLogEntryNote,
    }: {
      logId: number;
      newLogEntryCreatedAt: null | string;
      newLogEntryData: LogEntryDataValue;
      newLogEntryNote: null | string;
    }) {
      const payload = {
        log_entry: {
          created_at: newLogEntryCreatedAt,
          data: newLogEntryData,
          log_id: logId,
          note: newLogEntryNote,
        },
      };

      const data = await kyApi
        .post<
          Intersection<LogEntry, LogEntryCreateResponse>
        >(Routes.api_log_entries_path(), { json: payload })
        .json();

      this.addLogEntry({ logId, newLogEntry: data });
    },

    deleteLastLogEntry({ log }: { log: Log }) {
      const lastLogEntry = assert(last(sortBy(log.log_entries, 'created_at')));
      this.destroyLogEntry({ log, logEntry: lastLogEntry });
    },

    async deleteLog({ log: logToDelete }: { log: Log }) {
      await kyApi.delete(Routes.api_log_path({ id: logToDelete.id }));
      toast(`Deleted "${logToDelete.name}" log.`);
      this.router.push({ name: 'logs-index' });
      // we need to wait a tick so we don't remove the log while still on the log show page
      setTimeout(() => {
        this.logs = this.logs.filter((log) => log.id !== logToDelete.id);
      });
    },

    deleteLogEntry({
      log,
      logEntry: logEntryToDelete,
    }: {
      log: Log;
      logEntry: LogEntry;
    }) {
      log.log_entries = log.log_entries?.filter(
        (logEntry) => logEntry.id !== logEntryToDelete.id,
      );
    },

    async deleteLogShare({
      log,
      logShareId,
    }: {
      log: Log;
      logShareId: number;
    }) {
      await kyApi.delete(Routes.api_log_share_path({ id: logShareId }));
      log.log_shares = log.log_shares?.filter(
        (logShare) => logShare.id !== logShareId,
      );
    },

    async destroyLogEntry({ logEntry, log }: { logEntry: LogEntry; log: Log }) {
      await kyApi.delete(
        Routes.api_log_entry_path({ id: logEntry.id }, { log_id: log.id }),
      );
      this.deleteLogEntry({ log, logEntry });
    },

    async fetchAllLogEntries() {
      const data = await kyApi
        .get<
          Intersection<Array<LogEntry>, LogEntriesIndexResponse>
        >(Routes.api_log_entries_path())
        .json();
      const entriesByLogId: { [key: string]: Array<LogEntry> } = {};
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
      const data = await kyApi
        .get<
          Intersection<Array<LogEntry>, LogEntriesIndexResponse>
        >(Routes.api_log_entries_path({ log_id: logId }))
        .json();

      this.setLogEntries({
        log: this.logById({ logId }),
        logEntries: data,
      });
    },

    modifyLogEntry({ logEntry }: { logEntry: LogEntry }) {
      const log = this.logById({ logId: logEntry.log_id });

      log.log_entries = log.log_entries?.map((loopLogEntry) => {
        if (loopLogEntry.id === logEntry.id) {
          return logEntry;
        } else {
          return loopLogEntry;
        }
      });
    },

    setLogEntries({
      log,
      logEntries,
    }: {
      log: Log;
      logEntries: Array<LogEntry>;
    }) {
      log.log_entries = sortBy(logEntries, 'created_at');
    },

    async updateLog({
      logId,
      updatedLogParams,
    }: {
      logId: number;
      updatedLogParams: {
        publicly_viewable?: boolean;
        reminder_time_in_seconds?: number | null;
      };
    }) {
      const payload = { log: updatedLogParams };

      const updatedLogData = await kyApi
        .patch<
          Intersection<Log, LogUpdateResponse>
        >(Routes.api_log_path(logId), { json: payload })
        .json();

      const log = this.logById({ logId });

      typesafeAssign(log, updatedLogData);
    },

    async updateLogEntry({
      logEntryId,
      updatedLogEntryParams,
    }: {
      logEntryId: number;
      updatedLogEntryParams: {
        data: LogEntryDataValue;
      };
    }) {
      const payload = {
        log_entry: updatedLogEntryParams,
      };

      const updatedLogEntryData = await kyApi
        .patch<
          Intersection<LogEntry, LogEntryUpdateResponse>
        >(Routes.api_log_entry_path(logEntryId), { json: payload })
        .json();

      this.modifyLogEntry({
        logEntry: updatedLogEntryData,
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
      return this.logs.find((log) => log.slug === slug);
    },
  },
});
