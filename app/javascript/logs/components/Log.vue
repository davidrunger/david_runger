<template lang="pug">
div
  h1.text-2xl.mb-2 {{log.name}}
  h2.h5.text-neutral-400(v-if='!isOwnLog') shared by {{log.user.email}}
  p.h5.mb-4.description {{log.description}}
  NewLogEntryForm(:log='log' v-if='renderInputAtTop')
  div.mb-4(v-if='log.log_entries === undefined').
    Loading...
  LogDataDisplay(
    v-else-if='log.log_entries.length'
    :dataLabel='log.data_label'
    :dataType='log.data_type'
    :log='log'
    :logEntries='log.log_entries'
  )
  .my-8(v-else) There are no log entries for this log.
  .controls(v-if='isOwnLog')
    NewLogEntryForm(
      v-if='!renderInputAtTop'
      :log='log'
    )
    .mt-2(v-if='showDeleteLastEntryButton')
      el-button(@click='destroyLastEntry') Delete last entry
    .mt-2
      el-button.multi-line(
        @click="modalStore.showModal({ modalName: 'edit-log-shared-emails' })"
      )
        div.h4 Sharing settings
        div.h6
          span(v-if='publiclyViewable') Viewable by any user
          span(v-else) Shared with {{log.log_shares.length}} emails
    .mt-2
      el-button.multi-line(
        @click="modalStore.showModal({ modalName: 'edit-log-reminder-schedule' })"
      )
        div.h4 Reminder settings
        div.h6
          span(v-if='log.reminder_time_in_seconds')
            | {{(log.reminder_time_in_seconds / (60 * 60)).toFixed()}} hours
          span(v-else) No reminders
    .mt-2
      el-button(@click='destroyLog') Delete log

  Modal(name='edit-log-shared-emails' width='85%' maxWidth='600px' backgroundClass='bg-black')
    slot
      h3.font-bold.mb-4 Sharing
      div
        el-checkbox(
          v-model='publiclyViewable'
          @change='savePubliclyViewableChange'
        ) Publicly viewable
      div(v-if='isOwnLog && !publiclyViewable')
        el-tag(
          :key='logShare.email'
          v-for='logShare in logSharesSortedByLowercasedEmail'
          closable
          :disable-transitions='false'
          @close='handleLogShareDeletion(logShare)'
        ) {{logShare.email}}
        el-input(
          class='input-new-tag'
          v-if='inputVisible'
          v-model='inputValue'
          ref='saveTagInput'
          @keyup.enter.native='handleLogShareCreation'
          @blur='handleLogShareCreation'
        )
        el-button(v-else class='button-new-tag' size='small' @click='showInput') + Share with email
      div.mt-2 Shareable link: {{shareableUrl}}
      div
        el-button(size='small' @click='copyShareableUrlToClipboard')
          span(v-if='wasCopiedRecently') Copied!
          span(v-else) Copy to clipboard
      div.mt-2
        a.js-link(
          @click="modalStore.hideModal({ modalName: 'edit-log-shared-emails' })"
        ) Close

  Modal(name='edit-log-reminder-schedule' width='85%' maxWidth='600px' backgroundClass='bg-black')
    slot
      LogReminderScheduleForm(:log='log')
</template>

<script setup lang="ts">
import { useTitle } from '@vueuse/core';
import { ElInput } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, h, nextTick, ref } from 'vue';

import actionCableConsumer from '@/channels/consumer';
import { useBootstrap } from '@/lib/composables/useBootstrap';
import { useLogsStore } from '@/logs/store';
import type {
  Bootstrap,
  Log,
  LogDataType,
  LogEntry,
  LogShare,
} from '@/logs/types';
import * as RoutesType from '@/rails_assets/routes';
import { useModalStore } from '@/shared/modal/store';

import CounterBarGraph from './data_renderers/CounterBarGraph.vue';
import DurationTimeseries from './data_renderers/DurationTimeseries.vue';
import IntegerTimeseries from './data_renderers/IntegerTimeseries.vue';
import TextLog from './data_renderers/TextLog.vue';
import LogReminderScheduleForm from './LogReminderScheduleForm.vue';
import NewLogEntryForm from './NewLogEntryForm.vue';

declare const Routes: typeof RoutesType;

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
  counter: CounterBarGraph,
  duration: DurationTimeseries,
  number: IntegerTimeseries,
  text: TextLog,
};

const LogDataDisplay = (props: {
  dataType: LogDataType;
  log: Log;
  logEntries: Array<LogEntry>;
  dataLabel: string;
}) => {
  const DataRenderer = PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[props.dataType];
  return h(DataRenderer, {
    log: props.log,
    logEntries: props.logEntries,
    dataLabel: props.dataLabel,
  });
};
LogDataDisplay.props = ['dataType', 'log', 'logEntries', 'dataLabel'];

const logsStore = useLogsStore();
const modalStore = useModalStore();
const log = logsStore.unsafeSelectedLog;
const bootstrap = useBootstrap();

useTitle(`${log.name} - Logs - David Runger`);

const publiclyViewable = ref(log.publicly_viewable);
const inputVisible = ref(false);
const inputValue = ref('');
const wasCopiedRecently = ref(false);
const saveTagInput = ref(null);

const { isOwnLog } = storeToRefs(logsStore);

const logSharesSortedByLowercasedEmail = computed((): Array<LogShare> => {
  return log.log_shares
    .slice()
    .sort((a, b) => a.email.toLowerCase().localeCompare(b.email.toLowerCase()));
});

const renderInputAtTop = computed((): boolean => {
  return log.data_type === 'text';
});

const shareableUrl = computed((): string => {
  return (
    window.location.origin +
    Routes.user_shared_log_path(
      (bootstrap as Bootstrap).current_user.id,
      log.slug,
    )
  );
});

const showDeleteLastEntryButton = computed((): boolean => {
  return !['text'].includes(log.data_type);
});

function copyShareableUrlToClipboard() {
  navigator.clipboard.writeText(shareableUrl.value);

  wasCopiedRecently.value = true;

  setTimeout(() => {
    wasCopiedRecently.value = false;
  }, 1800);
}

function destroyLastEntry() {
  const confirmation = window.confirm(
    `Are you sure that you want to delete the last entry from the ${log.name} log?`,
  );

  if (confirmation === true) {
    logsStore.deleteLastLogEntry({ log });
  }
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

function handleLogShareDeletion(logShare: LogShare) {
  logsStore.deleteLogShare({
    log,
    logShareId: logShare.id,
  });
}

function handleLogShareCreation() {
  if (inputValue.value) {
    logsStore.addLogShare({
      logId: log.id,
      newLogShareEmail: inputValue.value,
    });
  }
  inputVisible.value = false;
  inputValue.value = '';
}

function savePubliclyViewableChange(newPubliclyViewableState: boolean) {
  logsStore.updateLog({
    logId: log.id,
    updatedLogParams: { publicly_viewable: newPubliclyViewableState },
  });
}

function showInput() {
  inputVisible.value = true;
  nextTick(() => {
    (saveTagInput.value as unknown as typeof ElInput).$refs.input.focus();
  });
}

function subscribeToLogEntriesChannel() {
  actionCableConsumer.subscriptions.create(
    {
      channel: 'LogEntriesChannel',
      log_id: log.id,
    },
    {
      received: (data) => {
        logsStore.addLogEntry({
          logId: log.id,
          newLogEntry: data,
        });
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

.el-tag:not(:first-of-type),
.button-new-tag {
  margin-top: 10px;
}

.el-tag + .el-tag,
.el-tag + .button-new-tag {
  margin-left: 10px;
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
