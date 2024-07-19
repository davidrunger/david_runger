<template lang="pug">
.flex.justify-center
  .container
    table.text-log-table
      TransitionGroup(name='appear-vertically-list')
        EditableTextLogRow(
          v-for='(logEntry, index) in sortedLogEntries'
          :key='logEntry.id'
          :log='log'
          :logEntry='logEntry'
          :class="{ '!transition-none': index !== 0 }"
        )
    el-button(v-if='!showAllEntries' @click='showAllEntries = true').
      Show all entries
</template>

<script lang="ts">
import { PropType } from 'vue';

import EditableTextLogRow from '@/logs/components/EditableTextLogRow.vue';
import { Log, TextLogEntry } from '@/logs/types';

export default {
  components: {
    EditableTextLogRow,
  },

  props: {
    log: {
      type: Object as PropType<Log>,
      required: true,
    },
    logEntries: {
      type: Array as PropType<Array<TextLogEntry>>,
      required: true,
    },
  },

  data() {
    return {
      showAllEntries: false,
    };
  },

  computed: {
    sortedLogEntries(): Array<TextLogEntry> {
      let logEntriesToShow;
      if (this.showAllEntries || this.logEntries.length <= 3) {
        logEntriesToShow = this.logEntries;
      } else {
        logEntriesToShow = this.logEntries.slice(this.logEntries.length - 3);
      }

      return logEntriesToShow.slice().reverse();
    },
  },
};
</script>

<style lang="scss">
ol {
  counter-reset: item;

  $li-indent: 17px;

  li {
    display: block;
    margin-bottom: -13px;
    margin-left: $li-indent;

    &::before {
      margin-left: -1 * $li-indent;
      content: counter(item) '. ';
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
    border-top: 1px solid #999;

    &:first-of-type {
      border-top: none;
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
