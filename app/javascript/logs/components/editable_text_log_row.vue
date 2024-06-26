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
    a.js-link(@click='editing = true') Edit
</template>

<script lang="ts">
import createDOMPurify from 'dompurify';
import { ElInput } from 'element-plus';
import { marked } from 'marked';
import strftime from 'strftime';

import { useLogsStore } from '@/logs/store';

const DOMPurify = createDOMPurify(window);

export default {
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

  data() {
    return {
      editing: false,
      logsStore: useLogsStore(),
      newPlaintext: this.logEntry.data.slice(),
    };
  },

  methods: {
    cancelEditing() {
      this.newPlaintext = this.logEntry.data.slice(); // undo any changes made
      this.editing = false;
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

  props: {
    logEntry: {
      type: Object,
      required: true,
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
};
</script>

<style scoped>
:deep(textarea.el-textarea__inner) {
  width: 100%;
  resize: vertical;
  height: 12rem;
}
</style>
