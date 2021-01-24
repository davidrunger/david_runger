<template lang='pug'>
tr
  td {{logEntry.createdAt}}

  td(v-if='editing')
    el-input(v-model='newPlaintext' type='textarea' ref='textInput')
  td.left-align(v-else v-html='logEntry.html')

  td(v-if='editing')
    el-button(@click='updateLogEntry' size='mini') Save
    el-button(@click='cancelEditing' size='mini') Cancel
  td(v-else)
    a.js-link(@click='editing = true') Edit
</template>

<script>
export default {
  data() {
    return {
      editing: false,
      newPlaintext: this.logEntry.plaintext.slice(),
    };
  },

  methods: {
    cancelEditing() {
      this.newPlaintext = this.logEntry.plaintext.slice(); // undo any changes made
      this.editing = false;
    },

    updateLogEntry() {
      const updatedLogEntryParams = { data: this.newPlaintext };
      this.$store.dispatch('updateLogEntry', {
        logEntryId: this.logEntry.id,
        updatedLogEntryParams,
      }).
        then(() => { this.editing = false; });
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
