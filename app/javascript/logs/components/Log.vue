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
    :data_label='log.data_label'
    :data_type='log.data_type'
    :log='log'
    :log_entries='log.log_entries'
  )
  .my-8(v-else) There are no log entries for this log.
  .controls(v-if='isOwnLog')
    NewLogEntryForm(
      v-if='!renderInputAtTop'
      :log='log'
    )
    .mt-2
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

<script lang="ts">
import { useTitle } from '@vueuse/core';
import { ElInput } from 'element-plus';
import { mapState } from 'pinia';
import { h } from 'vue';

import actionCableConsumer from '@/channels/consumer';
import { useLogsStore } from '@/logs/store';
import * as RoutesType from '@/rails_assets/routes';
import { useModalStore } from '@/shared/modal/store';

import { Bootstrap, Log, LogDataType, LogEntry, LogShare } from '../types';
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
  data_type: LogDataType;
  log: Log;
  log_entries: Array<LogEntry>;
  data_label: string;
}) => {
  const DataRenderer = PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[props.data_type];
  return h(DataRenderer, {
    log: props.log,
    log_entries: props.log_entries,
    data_label: props.data_label,
  });
};
LogDataDisplay.props = ['data_type', 'log', 'log_entries', 'data_label'];

export default {
  components: {
    LogDataDisplay,
    NewLogEntryForm,
    LogReminderScheduleForm,
  },

  computed: {
    ...mapState(useLogsStore, {
      isOwnLog: 'isOwnLog',
    }),

    logSharesSortedByLowercasedEmail(): Array<LogShare> {
      return this.log.log_shares
        .slice()
        .sort((a, b) =>
          a.email.toLowerCase().localeCompare(b.email.toLowerCase()),
        );
    },

    renderInputAtTop(): boolean {
      return this.log.data_type === 'text';
    },

    shareableUrl(): string {
      return (
        window.location.origin +
        Routes.user_shared_log_path(
          (this.$bootstrap as Bootstrap).current_user.id,
          this.log.slug,
        )
      );
    },
  },

  created() {
    this.ensureLogEntriesHaveBeenFetched();
    this.subscribeToLogEntriesChannel();
    this.publiclyViewable = this.log.publicly_viewable;
  },

  data() {
    return {
      inputVisible: false,
      inputValue: '',
      modalStore: useModalStore(),
      wasCopiedRecently: false,
      publiclyViewable: false,
    };
  },

  methods: {
    copyShareableUrlToClipboard() {
      navigator.clipboard.writeText(this.shareableUrl);

      this.wasCopiedRecently = true;

      setTimeout(() => {
        this.wasCopiedRecently = false;
      }, 1800);
    },

    destroyLastEntry() {
      const confirmation = window.confirm(
        `Are you sure that you want to delete the last entry from the ${this.log.name} log?`,
      );

      if (confirmation === true) {
        this.logsStore.deleteLastLogEntry({ log: this.log });
      }
    },

    destroyLog() {
      const promptResponse =
        prompt(`Are you sure you want to delete this log and all of its entries?
If so, enter the name of this log:
${this.log.name}`);

      if (promptResponse === this.log.name) {
        this.logsStore.deleteLog({ log: this.log });
      }
    },

    ensureLogEntriesHaveBeenFetched() {
      if (!this.log.log_entries) {
        this.logsStore.fetchLogEntries({ logId: this.log.id });
      }
    },

    handleLogShareDeletion(logShare: LogShare) {
      this.logsStore.deleteLogShare({
        log: this.log,
        logShareId: logShare.id,
      });
    },

    handleLogShareCreation() {
      const { inputValue } = this;
      if (inputValue) {
        this.logsStore.addLogShare({
          logId: this.log.id,
          newLogShareEmail: inputValue,
        });
      }
      this.inputVisible = false;
      this.inputValue = '';
    },

    savePubliclyViewableChange(newPubliclyViewableState: boolean) {
      this.logsStore.updateLog({
        logId: this.log.id,
        updatedLogParams: { publicly_viewable: newPubliclyViewableState },
      });
    },

    showInput() {
      this.inputVisible = true;
      this.$nextTick(() => {
        (this.$refs.saveTagInput as typeof ElInput).$refs.input.focus();
      });
    },

    subscribeToLogEntriesChannel() {
      actionCableConsumer.subscriptions.create(
        {
          channel: 'LogEntriesChannel',
          log_id: this.log.id,
        },
        {
          received: (data) => {
            this.logsStore.addLogEntry({
              logId: this.log.id,
              newLogEntry: data,
            });
          },
        },
      );
    },
  },

  setup() {
    const logsStore = useLogsStore();
    const log = logsStore.unsafeSelectedLog;

    useTitle(`${log.name} - Logs - David Runger`);

    return {
      log,
      logsStore,
    };
  },
};
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
