<template lang='pug'>
div
  h1.h2.mt3.mb1 {{log.name}}
  h2.h5.gray(v-if='!isOwnLog') shared by {{log.user.email}}
  p.h5.mb2.description {{log.description}}
  div.mb2(v-if='log.log_entries === undefined').
    Loading...
  log-data-display(
    v-else-if='log.log_entries.length'
    :data_label='log.data_label'
    :data_type='log.data_type'
    :log='log'
    :log_entries='log.log_entries'
  )
  div.my2(v-else) There are no log entries for this log.
  .controls(v-if='isOwnLog')
    new-log-entry-form(v-if='!renderInputAtTop' :log='log')
    .mt1
      el-button(@click='destroyLastEntry') Delete last entry
    .mt1
      el-button(
        @click="$store.commit('showModal', { modalName: 'edit-log-shared-emails' })"
      )
        div.h4 Sharing settings
        div.h6
          span(v-if='publiclyViewable') Viewable by any user
          span(v-else) Shared with {{log.log_shares.length}} emails
    .mt1
      el-button(
        @click="$store.commit('showModal', { modalName: 'edit-log-reminder-schedule' })"
      )
        div.h4 Reminder settings
        div.h6
          span(v-if='log.reminder_time_in_seconds')
            | {{(log.reminder_time_in_seconds / (60 * 60)).toFixed()}} hours
          span(v-else) No reminders
    .mt1
      el-button(@click='destroyLog') Delete log

  Modal(name='edit-log-shared-emails' width='85%' maxWidth='600px' backgroundClass='bg-black')
    slot
      h3.bold.mb2 Sharing
      div
        el-checkbox(
          v-model='publiclyViewable'
          @change='savePubliclyViewableChange'
        ) Publicly viewable
      div(v-if='!publiclyViewable')
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
          size='mini'
          @keyup.enter.native='handleLogShareCreation'
          @blur='handleLogShareCreation'
        )
        el-button(v-else class='button-new-tag' size='small' @click='showInput') + Share with email
      div.mt1 Shareable link: {{shareableUrl}}
      div
        el-button.copy-to-clipboard(size='mini')
          span(v-if='wasCopiedRecently') Copied!
          span(v-else) Copy to clipboard
      div.mt1
        el-button(
          @click="$store.commit('hideModal', { modalName: 'edit-log-shared-emails' })"
          type='text'
        ) Close

  Modal(name='edit-log-reminder-schedule' width='85%' maxWidth='600px' backgroundClass='bg-black')
    slot
      log-reminder-schedule-form(:log='log')
</template>

<script>
import ClipboardJS from 'clipboard';
import { mapGetters } from 'vuex';

import CounterBarGraph from './data_renderers/counter_bar_graph.vue';
import DurationTimeseries from './data_renderers/duration_timeseries.vue';
import IntegerTimeseries from './data_renderers/integer_timeseries.vue';
import TextLog from './data_renderers/text_log.vue';
import NewLogEntryForm from './new_log_entry_form.vue';
import LogReminderScheduleForm from './log_reminder_schedule_form.vue';

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
  counter: CounterBarGraph,
  duration: DurationTimeseries,
  number: IntegerTimeseries,
  text: TextLog,
};

const LogDataDisplay = {
  functional: true,
  render(h, context) {
    const DataRenderer = PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING[context.props.data_type];

    return h(DataRenderer, {
      props: {
        log: context.props.log,
        log_entries: context.props.log_entries,
        data_label: context.props.data_label,
      },
    });
  },
};

export default {
  components: {
    LogDataDisplay,
    NewLogEntryForm,
    LogReminderScheduleForm,
  },

  computed: {
    ...mapGetters({
      isOwnLog: 'isOwnLog',
      log: 'selectedLog',
    }),

    logSharesSortedByLowercasedEmail() {
      return this.log.log_shares.slice().
        sort((a, b) => a.email.toLowerCase().localeCompare(b.email.toLowerCase()));
    },

    renderInputAtTop() {
      return ['text'].indexOf(this.log.data_type) >= 0;
    },

    shareableUrl() {
      return window.location.origin + Routes.user_shared_log_path({
        user_id: this.bootstrap.current_user.id,
        slug: this.log.slug,
      });
    },
  },

  created() {
    this.ensureLogEntriesHaveBeenFetched();
    this.publiclyViewable = this.log.publicly_viewable;
  },

  data() {
    return {
      inputVisible: false,
      inputValue: '',
      wasCopiedRecently: false,
      publiclyViewable: false,
    };
  },

  methods: {
    destroyLastEntry() {
      const confirmation = window.confirm(
        `Are you sure that you want to delete the last entry from the ${this.log.name} log?`,
      );

      if (confirmation === true) {
        this.$store.dispatch('deleteLastLogEntry', { log: this.log });
      }
    },

    destroyLog() {
      const confirmation = window.confirm(
        `Are you sure that you want to delete the ${this.log.name} log and all of its log entries?`,
      );

      if (confirmation === true) {
        this.$store.dispatch('deleteLog', { log: this.log });
      }
    },

    ensureLogEntriesHaveBeenFetched() {
      if (!this.log.log_entries) {
        this.$store.dispatch('fetchLogEntries', { logId: this.log.id });
      }
    },

    handleLogShareDeletion(logShare) {
      this.$store.dispatch('deleteLogShare', {
        log: this.log,
        logShareId: logShare.id,
      });
    },

    handleLogShareCreation() {
      const { inputValue } = this;
      if (inputValue) {
        this.$store.dispatch('addLogShare', {
          logId: this.log.id,
          newLogShareEmail: inputValue,
        });
      }
      this.inputVisible = false;
      this.inputValue = '';
    },

    savePubliclyViewableChange(newPubliclyViewableState) {
      this.$store.dispatch('updateLog', {
        logId: this.log.id,
        updatedLogParams: { publicly_viewable: newPubliclyViewableState },
      });
    },

    showInput() {
      this.inputVisible = true;
      this.$nextTick(_ => {
        this.$refs.saveTagInput.$refs.input.focus();
      });
    },
  },

  mounted() {
    const clipboard = new ClipboardJS('.copy-to-clipboard', {
      text: () => this.shareableUrl,
    });
    clipboard.on('success', () => {
      this.wasCopiedRecently = true;
      setTimeout(() => { this.wasCopiedRecently = false; }, 1800);
    });
  },

  title() {
    return `${this.log.name} - Logs - David Runger`;
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
</style>
