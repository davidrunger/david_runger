<template lang="pug">
div
  h1.text-2xl.mb-2 {{ log.name }}
  h2.h5.text-neutral-400(v-if="isSharedLogView") shared by {{ log.user.email }}
  p.h5.mb-4.description {{ log.description }}
  NewLogEntryForm(
    :log="log"
    v-if="renderInputAtTop"
  )
  .mb-4(v-if="log.log_entries === undefined").
    Loading...
  LogDataDisplay(
    v-else-if="log.log_entries.length"
    :log="log"
  )
  .my-8(v-else) There are no log entries for this log.
  .controls(v-if="!isSharedLogView")
    NewLogEntryForm(
      v-if="!renderInputAtTop"
      :log="log"
    )
    .mt-2(v-if="showDeleteLastEntryButton")
      el-popconfirm(
        title="Delete the last log entry?"
        @confirm="destroyLastEntry"
      )
        template(#reference)
          el-button Delete last entry
    .mt-2
      el-button(
        tag="a"
        :href="download_log_path(log.slug)"
        download
      ) Download CSV
    .mt-2
      el-button.multi-line(
        @click="modalStore.showModal({ modalName: 'edit-log-sharing-settings' })"
      )
        .h4 Sharing settings
        .h6
          span(v-if="log.publicly_viewable") Viewable by any user
          span(v-else) Shared with {{ assert(log.log_shares).length }} emails
    .mt-2
      el-button.multi-line(
        @click="modalStore.showModal({ modalName: 'edit-log-reminder-schedule' })"
      )
        .h4 Reminder settings
        .h6
          span(v-if="log.reminder_time_in_seconds")
            | {{ (log.reminder_time_in_seconds / (60 * 60)).toFixed() }} hours
          span(v-else) No reminders
    .mt-2
      el-button(@click="destroyLog") Delete log

  EditLogSharingSettingsModal

  EditLogRemindersModal(:log="log")
</template>

<script setup lang="ts">
import { useTitle } from '@vueuse/core';
import { ElButton, ElPopconfirm } from 'element-plus';
import Cookies from 'js-cookie';
import { storeToRefs } from 'pinia';
import { computed, h } from 'vue';

import actionCableConsumer from '@/channels/consumer';
import { assert } from '@/lib/helpers';
import { useModalStore } from '@/lib/modal/store';
import { useLogsStore } from '@/logs/store';
import type { Log, LogEntryBroadcast } from '@/logs/types';
import { download_log_path } from '@/rails_assets/routes';

import CounterBarGraph from './data_renderers/CounterBarGraph.vue';
import DurationTimeseries from './data_renderers/DurationTimeseries.vue';
import IntegerTimeseries from './data_renderers/IntegerTimeseries.vue';
import TextLog from './data_renderers/TextLog.vue';
import EditLogRemindersModal from './EditLogRemindersModal.vue';
import EditLogSharingSettingsModal from './EditLogSharingSettingsModal.vue';
import NewLogEntryForm from './NewLogEntryForm.vue';

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
  counter: CounterBarGraph,
  duration: DurationTimeseries,
  number: IntegerTimeseries,
  text: TextLog,
};

const LogDataDisplay = (props: { log: Log }) => {
  const DataRenderer =
    PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[props.log.data_type];
  return h(DataRenderer, {
    log: props.log,
  });
};
LogDataDisplay.props = ['log'];

const logsStore = useLogsStore();
const modalStore = useModalStore();
const log = assert(logsStore.selectedLog);

useTitle(`${log.name} - Logs - David Runger`);

const { isSharedLogView } = storeToRefs(logsStore);

const renderInputAtTop = computed((): boolean => {
  return log.data_type === 'text';
});

const showDeleteLastEntryButton = computed((): boolean => {
  return !['text'].includes(log.data_type);
});

function destroyLastEntry() {
  logsStore.deleteLastLogEntry({ log });
}

function destroyLog() {
  const promptResponse =
    prompt(`Are you sure you want to delete this log and all of its entries?
If so, enter the name of this log:
${log.name}`);

  if (promptResponse === log.name) {
    logsStore.deleteLog({ log });
  }
}

function ensureLogEntriesHaveBeenFetched() {
  if (!log.log_entries) {
    logsStore.fetchLogEntries({ logId: log.id });
  }
}

function subscribeToLogEntriesChannel() {
  actionCableConsumer.subscriptions.create(
    {
      channel: 'LogEntriesChannel',
      log_id: log.id,
    },
    {
      connected() {
        // NOTE: This is for tests, so that we can wait until the WebSocket is connected.
        window.davidrunger.connectedToLogEntriesChannel = true;
      },

      received(data: LogEntryBroadcast) {
        if (Cookies.get('browser_uuid') === data.acting_browser_uuid) return;

        const { action, model } = data;

        if (action === 'created') {
          logsStore.addLogEntry({
            logId: log.id,
            newLogEntry: model,
          });
        } else if (action === 'updated') {
          logsStore.modifyLogEntry({
            logEntry: model,
          });
        } else if (action === 'destroyed') {
          logsStore.deleteLogEntry({
            log,
            logEntry: model,
          });
        }
      },
    },
  );
}

ensureLogEntriesHaveBeenFetched();
subscribeToLogEntriesChannel();
</script>

<style scoped>
.description {
  font-weight: 200;
}

.el-button {
  height: auto;
}

:deep(.el-button.multi-line > span) {
  display: block;
}

:deep(.el-input__wrapper) {
  background-color: var(--main-bg-color);
}
</style>
