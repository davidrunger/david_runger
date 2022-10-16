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
    div(:class='{mt1: isText}')
      el-date-picker(
        :class='{mb1: isNumeric}'
        v-model='newLogEntryCreatedAt'
        type='datetime'
        placeholder='Backdate (optional)'
      )
      el-input.new-log-input(
        :class='{mb1: isNumeric}'
        v-if='isNumeric'
        placeholder='Note (optional)'
        v-model='newLogEntryNote'
        type='text'
      )
      el-button(
        native-type='submit'
        :disabled='v$.$invalid'
      ) Add
</template>

<script>
import { required } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';

const MAX_RECENT_LOG_ENTRY_VALUES = 5;

export default {
  computed: {
    inputType() {
      if (this.isText) {
        return 'textarea';
      } else if (this.isCounter) {
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

    isNumeric() {
      return this.isCounter || this.isDuration || this.isNumber;
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

  setup: () => ({ v$: useVuelidate() }),

  validations() {
    return {
      newLogEntryData: { required },
    };
  },
};
</script>

<style lang='scss' scoped>
:deep(form.number),
form.duration {
  margin: 0 auto;
  max-width: 200px;
}

:deep(.el-input__wrapper) {
  width: 200px;
}

// double selector ensures that this rule has precedence over `.el-input` display
:deep(.el-date-editor.el-date-editor) {
  display: inline-block;
}
</style>
