<template lang="pug">
div
  form.px-2(
    @submit.prevent='postNewLogEntry(newLogEntryData)'
    :class='log.data_type'
  )
    .mb-2(v-if='isCounter')
      el-button(
        v-for='logEntryValue in mostRecentLogEntryValues'
        :key='logEntryValue'
        @click='postNewLogEntry(logEntryValue)'
      ) {{logEntryValue}}
    .flex.justify-center
      .container
        el-input.new-log-input.mb-2(
          :placeholder='log.data_label'
          v-model='newLogEntryData'
          name='log.data_label'
          ref='log-input'
          :type='inputType'
        )
    div(:class='{"mt-2": isText}')
      el-date-picker(
        :class='{"mb-2": isNumeric}'
        v-model='newLogEntryCreatedAt'
        type='datetime'
        placeholder='Backdate (optional)'
      )
      el-input.new-log-input(
        :class='{"mb-2": isNumeric}'
        v-if='isDuration || isNumber'
        placeholder='Note (optional)'
        v-model='newLogEntryNote'
        type='text'
      )
      el-button(
        native-type='submit'
        :disabled='v$.$invalid'
      ) Add
</template>

<script lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElInput } from 'element-plus';

import { useLogsStore } from '@/logs/store';
import { LogEntryDataValue } from '@/logs/types';

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

    isCounter(): boolean {
      return this.log.data_type === 'counter';
    },

    isDuration(): boolean {
      return this.log.data_type === 'duration';
    },

    isNumber(): boolean {
      return this.log.data_type === 'number';
    },

    isNumeric(): boolean {
      return this.isCounter || this.isDuration || this.isNumber;
    },

    isText(): boolean {
      return this.log.data_type === 'text';
    },

    mostRecentLogEntryValues(): Array<LogEntryDataValue> {
      if (!this.log.log_entries) return [];

      const mostRecentLogEntryValues = [];

      for (const logEntry of this.log.log_entries.slice().reverse()) {
        if (mostRecentLogEntryValues.length >= MAX_RECENT_LOG_ENTRY_VALUES)
          break;

        const value = logEntry.data;
        const isAlreadyInList = mostRecentLogEntryValues.indexOf(value) !== -1;
        if (!isAlreadyInList) {
          mostRecentLogEntryValues.push(value);
        }
      }

      return mostRecentLogEntryValues.sort((a, b) => a - b);
    },
  },

  data() {
    return {
      logsStore: useLogsStore(),
      newLogEntryCreatedAt: null as null | string,
      newLogEntryData: null as null | LogEntryDataValue,
      newLogEntryNote: null as null | string,
    };
  },

  methods: {
    focusLogEntryInput() {
      setTimeout(() => {
        (this.$refs['log-input'] as typeof ElInput).focus();
      });
    },

    async postNewLogEntry(newLogEntryData: LogEntryDataValue | null) {
      if (newLogEntryData === null) return;

      await this.logsStore.createLogEntry({
        logId: this.log.id,
        newLogEntryCreatedAt: this.newLogEntryCreatedAt,
        newLogEntryData,
        newLogEntryNote: this.newLogEntryNote,
      });

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

<style lang="scss" scoped>
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
