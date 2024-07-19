<template lang="pug">
tr
  td(v-html='formattedCreatedAt')

  td(v-if='editing')
    el-input(v-model='newPlaintext' type='textarea' ref='textInput')
  td.left-align(v-else v-html='html')

  td(v-if='editing')
    el-button(@click='updateLogEntry' size='small') Save
    el-button(@click='cancelEditing' size='small') Cancel
  td(v-else)
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

<script lang="ts">
import createDOMPurify from 'dompurify';
import { ElInput } from 'element-plus';
import { marked } from 'marked';
import strftime from 'strftime';
import { PropType } from 'vue';

import { useLogsStore } from '@/logs/store';
import type { Log, TextLogEntry } from '@/logs/types';

const DOMPurify = createDOMPurify(window);

export default {
  props: {
    log: {
      type: Object as PropType<Log>,
      required: true,
    },
    logEntry: {
      type: Object as PropType<TextLogEntry>,
      required: true,
    },
  },

  data() {
    return {
      editing: false,
      logsStore: useLogsStore(),
      newPlaintext: this.logEntry.data.slice(),
    };
  },

  computed: {
    formattedCreatedAt(): string {
      return strftime(
        '%b %-d, %Y at&nbsp;%-l:%M%P',
        new Date(this.logEntry.created_at),
      );
    },

    html(): string {
      return DOMPurify.sanitize(
        marked(this.logEntry.data, { async: false }) as string,
      );
    },
  },

  watch: {
    editing() {
      setTimeout(() => {
        if (this.editing) {
          (
            (this.$refs.textInput as typeof ElInput).$el
              .children[0] as HTMLInputElement
          ).focus();
        }
      }, 0);
    },
  },

  methods: {
    cancelEditing() {
      this.newPlaintext = this.logEntry.data.slice(); // undo any changes made
      this.editing = false;
    },

    destroyLogEntry() {
      this.logsStore.destroyLogEntry({
        logEntry: this.logEntry,
        log: this.log,
      });
    },

    async updateLogEntry() {
      const updatedLogEntryParams = { data: this.newPlaintext };
      await this.logsStore.updateLogEntry({
        logEntryId: this.logEntry.id,
        updatedLogEntryParams,
      });
      this.editing = false;
    },
  },
};
</script>

<style scoped>
:deep(textarea.el-textarea__inner) {
  width: 100%;
  resize: vertical;
  height: 12rem;
}
</style>
