<template lang='pug'>
div
  form.px1(
    @submit.prevent='postNewLogEntry(newLogEntryData)'
    :class='log.data_type'
  )
    .mb1(v-if='isCounter')
      el-button(
        v-for='logEntryValue in mostRecentLogEntryValues'
        :key='logEntryValue'
        @click='postNewLogEntry(logEntryValue)'
      ) {{logEntryValue}}
    .flex.justify-center
      .container
        el-input.new-log-input.mb1(
          :placeholder='log.data_label'
          v-model='newLogEntryData'
          name='log.data_label'
          ref='log-input'
          :type='inputType'
        )
    el-date-picker.mb1.mr1(
      v-model='newLogEntryCreatedAt'
      type='datetime'
      placeholder='Backdate (optional)'
    )
    el-input.new-log-input.mb1(
      v-if='isCounter || isDuration || isNumber'
      placeholder='Note (optional)'
      v-model='newLogEntryNote'
      type='text'
    )
    el-button(
      native-type='submit'
    ) Add
</template>

<script>
const MAX_RECENT_LOG_ENTRY_VALUES = 5;

export default {
  computed: {
    inputType() {
      if (this.isText) {
        return 'textarea';
      } else if (this.isNumber || this.isCounter) {
        return 'number';
      } else {
        return 'text';
      }
    },

    isCounter() {
      return this.log.data_type === 'counter';
    },

    isDuration() {
      return this.log.data_type === 'duration';
    },

    isNumber() {
      return this.log.data_type === 'number';
    },

    isText() {
      return this.log.data_type === 'text';
    },

    mostRecentLogEntryValues() {
      if (!this.log.log_entries) return [];

      const mostRecentLogEntryValues = [];

      this.log.log_entries.slice().reverse().forEach((logEntry) => {
        if (mostRecentLogEntryValues.length >= MAX_RECENT_LOG_ENTRY_VALUES) return;

        const value = logEntry.data;
        const isAlreadyInList = mostRecentLogEntryValues.indexOf(value) !== -1;
        if (!isAlreadyInList) {
          mostRecentLogEntryValues.push(value);
        }
      });

      return mostRecentLogEntryValues.sort((a, b) => a - b);
    },
  },

  data() {
    return {
      newLogEntryCreatedAt: null,
      newLogEntryData: null,
      newLogEntryNote: null,
    };
  },

  methods: {
    focusLogEntryInput() {
      setTimeout(() => {
        this.$refs['log-input'].focus();
      });
    },

    postNewLogEntry(newLogEntryData) {
      this.$store.dispatch(
        'createLogEntry',
        {
          logId: this.log.id,
          newLogEntryCreatedAt: this.newLogEntryCreatedAt,
          newLogEntryData,
          newLogEntryNote: this.newLogEntryNote,
        },
      );
      this.newLogEntryCreatedAt = null;
      this.newLogEntryData = null;
      this.newLogEntryNote = null;
    },
  },

  mounted() {
    this.focusLogEntryInput();
  },

  props: {
    log: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang='scss' scoped>
:deep(form.number),
form.duration {
  margin: 0 auto;
  max-width: 200px;
}
</style>
