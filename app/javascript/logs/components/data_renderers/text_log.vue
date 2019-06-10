<template lang='pug'>
div
  el-table.my3(
    style='width: 100%'
    :data='formattedLogEntries'
    :show-header='false'
    :fit='true'
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
.el-table {
  color: #aaa;
}

.el-table .cell {
  word-break: initial;
  white-space: pre-wrap;
}

.el-table tr {
  background: black;
}

.el-table--enable-row-hover .el-table__body tr:hover > td {
  background: #333;
}

.el-table tr:last-child td {
  border-bottom: none;
}
</style>
