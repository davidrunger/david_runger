<template lang="pug">
tr
  td(v-html="formattedCreatedAt")

  td(v-if="editing")
    ElInput(
      v-model="newPlaintext"
      type="textarea"
      ref="textInput"
    )
  td.left-align(
    v-else
    v-html="html"
  )

  td(v-if="editing")
    ElButton(
      @click="updateLogEntry"
      size="small"
    ) Save
    ElButton(
      @click="cancelEditing"
      size="small"
    ) Cancel
  td(v-else)
    .flex.flex-wrap.items-center.justify-center.gap-1
      ElButton(
        @click="editing = true"
        link
        type="primary"
      ) Edit
      ElPopconfirm(
        title="Delete this log entry?"
        @confirm="destroyLogEntry"
      )
        template(#reference)
          ElButton(
            link
            type="danger"
          ) Delete
</template>

<script setup lang="ts">
import createDOMPurify from 'dompurify';
import { ElButton, ElInput, ElPopconfirm } from 'element-plus';
import { marked } from 'marked';
import strftime from 'strftime';
import { computed, nextTick, ref, watch } from 'vue';
import { object } from 'vue-types';

import { useLogsStore } from '@/logs/store';
import type { Log, TextLogEntry } from '@/logs/types';

const DOMPurify = createDOMPurify(window);

const props = defineProps({
  log: object<Log>().isRequired,
  logEntry: object<TextLogEntry>().isRequired,
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
  nextTick(() => {
    if (editing.value && textInput.value) {
      (
        (textInput.value as typeof ElInput).$el.children[0] as HTMLInputElement
      ).focus();
    }
  });
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

:deep(pre) {
  overflow-x: auto;
}
</style>

<style>
td:has(pre) {
  width: 100%;
  max-width: 0;
}
</style>
