<template lang='pug'>
.flex.justify-center
  .container
    NewLogEntryForm(:log='log')
    table
      EditableTextLogRow(
        v-for='logEntry in formattedLogEntries'
        :key='logEntry.id'
        :logEntry='logEntry'
      )
    el-button(v-if='!showAllEntries' @click='showAllEntries = true').
      Show all entries
</template>

<script>
import EditableTextLogRow from 'logs/components/editable_text_log_row.vue';
import NewLogEntryForm from 'logs/components/new_log_entry_form.vue';

import createDOMPurify from 'dompurify';
import marked from 'marked';
import strftime from 'strftime';

const DOMPurify = createDOMPurify(window);

export default {
  components: {
    EditableTextLogRow,
    NewLogEntryForm,
  },

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
          id: logEntry.id,
          createdAt: strftime('%b %-d %-l:%M%P', new Date(logEntry.created_at)),
          plaintext: logEntry.data,
          html: DOMPurify.sanitize(marked(logEntry.data)),
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
    log: {
      type: Object,
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

.container {
  max-width: 1000px;
}

.el-button--mini {
  padding: 6px 10px;
}

.el-button + .el-button {
  margin-left: 5px;
}

table {
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
    padding: 10px 0;
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
