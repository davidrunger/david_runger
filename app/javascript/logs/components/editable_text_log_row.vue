<template lang='pug'>
tr
  td {{logEntry.createdAt}}

  td(v-if='editing')
    textarea(v-model='newPlaintext')
  td.left-align(v-else v-html='logEntry.html')

  td(v-if='editing').
    #[a.js-link(@click='updateLogEntry') Save] #[a.js-link(@click='cancelEditing') Cancel]
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
};
</script>

<style>
textarea {
  width: 100%;
  resize: vertical;
}
</style>
