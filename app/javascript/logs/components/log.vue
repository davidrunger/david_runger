<template lang='pug'>
div
  h1.h2.mt3.mb1 {{log.name}}
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
  new-log-entry-form(v-if='!renderInputAtTop' :log='log')
  .mt1
    el-button(@click='destroyLastEntry') Delete last entry
  .mt1
    el-button(@click='destroyLog') Delete log
</template>

<script>
import { mapGetters } from 'vuex';

import DurationTimeseries from './data_renderers/duration_timeseries.vue';
import IntegerTimeseries from './data_renderers/integer_timeseries.vue';
import TextLog from './data_renderers/text_log.vue';
import NewLogEntryForm from './new_log_entry_form.vue';

const PUBLIC_TYPE_TO_DATA_RENDERER_MAPPING = {
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
  },

  computed: {
    ...mapGetters({
      log: 'selectedLog',
    }),

    renderInputAtTop() {
      return ['text'].indexOf(this.log.data_type) >= 0;
    },
  },

  created() {
    this.ensureLogEntriesHaveBeenFetched();
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
</style>
