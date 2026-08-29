<template lang="pug">
div
  form.px-2(
    @submit.prevent="postNewLogEntry(formData.newLogEntryData)"
    :class="[log.data_type, { 'flex flex-col items-center': !isText }]"
  )
    .mb-2(v-if="isCounter")
      ElButton(
        v-for="logEntryValue in mostRecentLogEntryValues"
        :key="logEntryValue"
        @click="postNewLogEntry(logEntryValue)"
      ) {{ logEntryValue }}
    .flex.justify-center
      .w-full.max-w-4xl
        ElInput.new-log-input.mb-2(
          :placeholder="log.data_label"
          v-model="formData.newLogEntryData"
          name="log.data_label"
          ref="logInput"
          :type="inputType"
        )
    div(:class="{ 'mt-2': isText, 'flex flex-col items-center': !isText }")
      .new-log-entry-created-at-wrapper(
        :class="{ 'is-pristine': !createdAtInputHasBeenInteracted, 'mb-2': isNumeric, 'mr-2': isText }"
      )
        span.new-log-entry-created-at-placeholder(
          v-if="!createdAtInputHasBeenInteracted && !formData.newLogEntryCreatedAt"
        ) Backdate (optional)
        input.new-log-entry-created-at(
          v-model="formData.newLogEntryCreatedAt"
          aria-label="Backdate (optional)"
          type="datetime-local"
          @focus="createdAtInputHasBeenInteracted = true"
        )
      ElInput.new-log-input(
        :class="{ 'mb-2': isNumeric }"
        v-if="isDuration || isNumber"
        placeholder="Note (optional)"
        v-model="formData.newLogEntryNote"
        type="text"
      )
      ElButton(
        native-type="submit"
        :disabled="v$.$invalid"
      ) Add
</template>

<script setup lang="ts">
import { useVuelidate } from '@vuelidate/core';
import { required } from '@vuelidate/validators';
import { ElButton, ElInput } from 'element-plus';
import { computed, nextTick, onMounted, reactive, ref } from 'vue';
import { object } from 'vue-types';

import { isMobileDevice } from '@/lib/isMobileDevice';
import { isArrayOfNumbers } from '@/lib/typePredicates';
import { useLogsStore } from '@/logs/store';
import { type Log } from '@/logs/types';
import type { LogEntryDataValue } from '@/types';

const MAX_RECENT_LOG_ENTRY_VALUES = 5;

const logInput = ref(null);

const props = defineProps({
  log: object<Log>().isRequired,
});

const vuelidateRules = {
  newLogEntryData: { required },
};

const formData = reactive({
  newLogEntryCreatedAt: '',
  newLogEntryData: null as null | LogEntryDataValue,
  newLogEntryNote: null as null | string,
});

const createdAtInputHasBeenInteracted = ref(false);

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
    // NOTE: We don't use a 'number' input for number logs because it forbids decimals.
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

  if (isArrayOfNumbers(mostRecentLogEntryValues)) {
    return mostRecentLogEntryValues.sort((a, b) => a - b);
  } else {
    return mostRecentLogEntryValues;
  }
});

onMounted(() => {
  // NOTE: Don't focus numeric logs on mobile because it scrolls the graph out
  // of the viewport.
  if (!(isMobileDevice() && isNumeric.value)) {
    focusLogEntryInput();
  }
});

function focusLogEntryInput() {
  nextTick(() => {
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
  createdAtInputHasBeenInteracted.value = false;
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
  flex-grow: revert;
  width: 200px;
}

:deep(.new-log-input) {
  width: 200px;
}

.new-log-entry-created-at-wrapper {
  display: inline-block;
  position: relative;
  vertical-align: middle;
}

.new-log-entry-created-at-placeholder {
  color: #999;
  display: flex;
  inset: 0;
  align-items: center;
  justify-content: center;
  padding: 0 0.5rem;
  pointer-events: none;
  position: absolute;
}

input.new-log-entry-created-at {
  background: var(--main-bg-color);
  height: 32px;
  color: rgb(170, 170, 170);
  color-scheme: dark;
  display: inline-block;
  width: 220px;
  border-color: var(--el-border-color);
  border-radius: var(--el-border-radius-base);

  &:focus-visible {
    outline: none;
  }
}

.new-log-entry-created-at-wrapper.is-pristine
  .new-log-entry-created-at-placeholder {
  opacity: 0.5;
}

.new-log-entry-created-at-wrapper.is-pristine input.new-log-entry-created-at {
  color: transparent;
}
</style>
