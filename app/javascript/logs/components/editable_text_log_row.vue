<template lang='pug'>
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

<script>
import { useLogsStore } from '@/logs/store';
import createDOMPurify from 'dompurify';
import { marked } from 'marked';
import strftime from 'strftime';

const DOMPurify = createDOMPurify(window);

export default {
  computed: {
    formattedCreatedAt() {
      return strftime('%b %-d, %Y at&nbsp;%-l:%M%P', new Date(this.logEntry.created_at));
    },

    html() {
      return DOMPurify.sanitize(marked(this.logEntry.data));
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
      const self = this;
      setTimeout(() => {
        if (self.editing) {
          self.$refs.textInput.$el.children[0].focus();
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
