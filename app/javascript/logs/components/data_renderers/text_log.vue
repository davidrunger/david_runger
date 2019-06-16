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
      align='left'
      min-width='500'
    )
      template(slot-scope='scope')
        div(v-html='formattedLogEntries[scope.$index].html')
  el-button(v-if='!showAllEntries' @click='showAllEntries = true').
    Show all entries
</template>

<script>
import marked from 'marked';
import strftime from 'strftime';

export default {
  computed: {
    formattedLogEntries() {
      let logEntriesToShow;
      if (this.showAllEntries) {
        logEntriesToShow = this.log_entries;
      } else {
        logEntriesToShow = this.log_entries.slice(this.log_entries.length - 3);
      }

      const sortedAndFormattedEntries =
        logEntriesToShow.map(logEntry => ({
          createdAt: strftime('%b %-d %-l:%M%P', new Date(logEntry.created_at)),
          html: marked(logEntry.data, { sanitize: true }),
        })).reverse();

      return sortedAndFormattedEntries;
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

<style lang='scss'>
// (re-)set some default styles for markdown formatting
em { font-style: italic; }
strong { font-weight: bold; }
h1 { font-size: 2em; }
h2 { font-size: 1.5em; }
h3 { font-size: 1.17em; }
h4 { font-size: 1em; }
h5 { font-size: 0.83em; }
h6 { font-size: 0.75em; }

ol {
  counter-reset: item;

  $li-indent: 17px;

  li {
    display: block;
    margin-bottom: -13px;
    margin-left: $li-indent;

    &::before {
      margin-left: -1 * $li-indent;
      content: counter(item) ". ";
      counter-increment: item;
      position: absolute;
    }
  }
}

.el-table {
  color: #aaa;
}

.el-table .cell {
  word-break: initial;
  white-space: pre-wrap;
  line-height: 1.13rem;
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
