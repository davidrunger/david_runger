<template lang='pug'>
div
  el-table(
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
</template>

<script>
import strftime from 'strftime';

export default {
  computed: {
    formattedLogEntries() {
      return this.log_entries.map(logEntry => ({
        createdAt: strftime('%b %-d %-l:%M%P', new Date(logEntry.created_at)),
        text: logEntry.data[this.data_label],
      }))
    },
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
