<template lang="pug">
div
  form.px-2(
    @submit.prevent="postNewLogEntry(formData.newLogEntryData)",
    :class="log.data_type"
  )
    .mb-2(v-if="isCounter")
      el-button(
        v-for="logEntryValue in mostRecentLogEntryValues",
        :key="logEntryValue"
        @click="postNewLogEntry(logEntryValue)"
      ) {{ logEntryValue }}
    .flex.justify-center
      .w-full.max-w-4xl
        el-input.new-log-input.mb-2(
          :placeholder="log.data_label"
          v-model="formData.newLogEntryData"
          name="log.data_label"
          ref="logInput",
          :type="inputType"
        )
    div(:class="{ 'mt-2': isText }")
      el-date-picker(
        :class="{ 'mb-2': isNumeric }"
        v-model="formData.newLogEntryCreatedAt"
        type="datetime"
        placeholder="Backdate (optional)"
      )
      el-input.new-log-input(
        :class="{ 'mb-2': isNumeric }"
        v-if="isDuration || isNumber"
        placeholder="Note (optional)"
        v-model="formData.newLogEntryNote"
        type="text"
      )
      el-button(native-type="submit", :disabled="v$.$invalid") Add
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElDatePicker, ElInput } from 'element-plus';
import { computed, onMounted, reactive, ref } from 'vue';

import { useLogsStore } from '@/logs/store';
import type { LogEntryDataValue } from '@/types';

const MAX_RECENT_LOG_ENTRY_VALUES = 5;

const logInput = ref(null);

const props = defineProps({
  log: {
    type: Object,
    required: true,
  },
});

const vuelidateRules = {
  newLogEntryData: { required },
};

const formData = reactive({
  newLogEntryCreatedAt: '',
  newLogEntryData: null as null | LogEntryDataValue,
  newLogEntryNote: null as null | string,
});

const v$ = useVuelidate(vuelidateRules, formData);

const logsStore = useLogsStore();

const isCounter = computed((): boolean => {
  return props.log.data_type === 'counter';
});

const isDuration = computed((): boolean => {
  return props.log.data_type === 'duration';
});

const isNumber = computed((): boolean => {
  return props.log.data_type === 'number';
});

const isNumeric = computed((): boolean => {
  return isCounter.value || isDuration.value || isNumber.value;
});

const isText = computed((): boolean => {
  return props.log.data_type === 'text';
});

const inputType = computed(() => {
  if (isText.value) {
    return 'textarea';
  } else if (isCounter.value) {
    return 'number';
  } else {
    return 'text';
  }
});

const mostRecentLogEntryValues = computed((): Array<LogEntryDataValue> => {
  if (!props.log.log_entries) return [];

  const mostRecentLogEntryValues = [];

  for (const logEntry of props.log.log_entries.slice().reverse()) {
    if (mostRecentLogEntryValues.length >= MAX_RECENT_LOG_ENTRY_VALUES) break;

    const value = logEntry.data;
    const isAlreadyInList = mostRecentLogEntryValues.indexOf(value) !== -1;
    if (!isAlreadyInList) {
      mostRecentLogEntryValues.push(value);
    }
  }

  return mostRecentLogEntryValues.sort((a, b) => a - b);
});

onMounted(() => {
  focusLogEntryInput();
});

function focusLogEntryInput() {
  setTimeout(() => {
    if (logInput.value) {
      (logInput.value as typeof ElInput).focus();
    }
  });
}

async function postNewLogEntry(newLogEntryData: LogEntryDataValue | null) {
  if (newLogEntryData === null) return;

  await logsStore.createLogEntry({
    logId: props.log.id,
    newLogEntryCreatedAt: formData.newLogEntryCreatedAt,
    newLogEntryData,
    newLogEntryNote: formData.newLogEntryNote,
  });

  formData.newLogEntryCreatedAt = '';
  formData.newLogEntryData = null;
  formData.newLogEntryNote = null;
}
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
