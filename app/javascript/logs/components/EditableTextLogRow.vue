<template lang="pug">
tr
  td(v-html='formattedCreatedAt')

  td(v-if='editing')
    el-input(
      v-model='newPlaintext'
      type='textarea'
      ref='textInput'
    )
  td.left-align(v-else v-html='html')

  td(v-if='editing')
    el-button(@click='updateLogEntry' size='small') Save
    el-button(@click='cancelEditing' size='small') Cancel
  td(v-else)
    .flex.flex-wrap.items-center.justify-center.gap-1
      el-button(
        @click='editing = true'
        link
        type='primary'
      ) Edit
      el-button(
        @click='destroyLogEntry'
        link
        type='danger'
      ) Delete
</template>

<script setup lang="ts">
import createDOMPurify from 'dompurify';
import { ElInput } from 'element-plus';
import { marked } from 'marked';
import strftime from 'strftime';
import { computed, ref, watch, type PropType } from 'vue';

import { useLogsStore } from '@/logs/store';
import type { Log, TextLogEntry } from '@/logs/types';

const DOMPurify = createDOMPurify(window);

const props = defineProps({
  log: {
    type: Object as PropType<Log>,
    required: true,
  },
  logEntry: {
    type: Object as PropType<TextLogEntry>,
    required: true,
  },
});

const logsStore = useLogsStore();
const editing = ref(false);
const textInput = ref(null);
const newPlaintext = ref(props.logEntry.data.slice());

const formattedCreatedAt = computed((): string => {
  return strftime(
    '%b %-d, %Y at&nbsp;%-l:%M%P',
    new Date(props.logEntry.created_at),
  );
});

const html = computed((): string => {
  return DOMPurify.sanitize(marked(props.logEntry.data, { async: false }));
});

watch(editing, () => {
  setTimeout(() => {
    if (editing.value && textInput.value) {
      (
        (textInput.value as typeof ElInput).$el.children[0] as HTMLInputElement
      ).focus();
    }
  }, 0);
});

function cancelEditing() {
  newPlaintext.value = props.logEntry.data.slice(); // undo any changes made
  editing.value = false;
}

function destroyLogEntry() {
  logsStore.destroyLogEntry({
    logEntry: props.logEntry,
    log: props.log,
  });
}

async function updateLogEntry() {
  const updatedLogEntryParams = { data: newPlaintext.value };
  await logsStore.updateLogEntry({
    logEntryId: props.logEntry.id,
    updatedLogEntryParams,
  });
  editing.value = false;
}
</script>

<style scoped>
:deep(textarea.el-textarea__inner) {
  width: 100%;
  resize: vertical;
  height: 12rem;
}

@media screen and (width <= 500px) {
  table.text-log-table.text-log-table td {
    min-width: 32px;
    width: initial;
  }

  .el-button.el-button + .el-button {
    margin-left: 0;
  }
}

td :deep(pre) {
  text-wrap-mode: unset;
}
</style>
