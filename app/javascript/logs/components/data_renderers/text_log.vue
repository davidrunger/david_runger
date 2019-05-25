<template lang='pug'>
div
  el-table.mb2(
    :data='formattedLogEntries'
    :show-header='true'
    :fit='true'
    style='width: 100%'
  )
    el-table-column(
      prop='createdAt'
      align='center'
      width='140'
    )
    el-table-column(
      prop='text'
      align='left'
      min-width='500'
    )
  el-button(v-if='!showAllEntries' @click='showAllEntries = true').
    Show all entries
</template>

<script>
import strftime from 'strftime';

export default {
  computed: {
    formattedLogEntries() {
      const sortedAndFormattedEntries =
        this.log_entries.map(logEntry => ({
          createdAt: strftime('%b %-d %-l:%M%P', new Date(logEntry.created_at)),
          text: logEntry.data,
        })).reverse();

      if (this.showAllEntries) {
        return sortedAndFormattedEntries;
      } else {
        return sortedAndFormattedEntries.slice(0, 3);
      }
    },
  },

  data() {
    return {
      showAllEntries: false,
    };
  },

  props: {
    data_label: {
      type: String,
      required: true,
    },
    log_entries: {
      type: Array,
      required: true,
    },
  },
};
</script>

<style>
.el-table .cell {
  word-break: initial;
}
</style>
