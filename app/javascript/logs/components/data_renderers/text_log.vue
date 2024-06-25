<template lang='pug'>
.flex.justify-center
  .container
    table.text-log-table(v-auto-animate)
      EditableTextLogRow(
        v-for='logEntry in sortedLogEntries'
        :key='logEntry.id'
        :logEntry='logEntry'
      )
    el-button(v-if='!showAllEntries' @click='showAllEntries = true').
      Show all entries
</template>

<script lang='ts'>
import EditableTextLogRow from '@/logs/components/editable_text_log_row.vue';
import NewLogEntryForm from '@/logs/components/new_log_entry_form.vue';
import { LogEntry } from '@/logs/types';
import { PropType } from 'vue';

export default {
  components: {
    EditableTextLogRow,
    NewLogEntryForm,
  },

  computed: {
    sortedLogEntries(): Array<LogEntry> {
      let logEntriesToShow;
      if (this.showAllEntries || (this.log_entries.length <= 3)) {
        logEntriesToShow = this.log_entries;
      } else {
        logEntriesToShow = this.log_entries.slice(this.log_entries.length - 3);
      }

      return logEntriesToShow.slice().reverse();
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
    log: {
      type: Object,
      required: true,
    },
    log_entries: {
      type: Array as PropType<Array<LogEntry>>,
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

.container {
  max-width: 1000px;
  width: 100%;
}

.el-button + .el-button {
  margin-left: 5px;
}

table.text-log-table {
  margin: 15px 0;
  color: #aaa;
  font-size: 14px;

  tr {
    border-bottom: 1px solid #999;

    &:last-of-type {
      border-bottom: none;
    }
  }

  td {
    padding: 5px 10px;
    word-break: initial;
    white-space: pre-wrap;
    line-height: 1.13rem;
    text-align: center;
    vertical-align: middle;
    min-width: 140px;

    &.left-align {
      text-align: left;
    }

    p {
      display: inline-block;

      &:not(:first-of-type) {
        margin-top: 10px;
      }
    }
  }
}
</style>
