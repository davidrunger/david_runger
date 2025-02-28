<template lang="pug">
div
  .flex.justify-center.w-full
    table.text-log-table.w-full.max-w-4xl
      TransitionGroup(name='appear-vertically-list')
        EditableTextLogRow(
          v-for='(logEntry, index) in sortedLogEntries',
          :key='logEntry.id',
          :log='log',
          :logEntry='logEntry',
          :class='{ "transition-none!": index !== 0 }'
        )
  el-button(v-if='!showAllEntries', @click='showAllEntries = true').
    Show all entries
</template>

<script setup lang="ts">
import { ElButton } from 'element-plus';
import { sortBy } from 'lodash-es';
import { computed, ref, type PropType } from 'vue';

import { isArrayOfTextLogEntries } from '@/lib/type_predicates';
import EditableTextLogRow from '@/logs/components/EditableTextLogRow.vue';
import type { Log, TextLogEntry } from '@/logs/types';

const props = defineProps({
  log: {
    type: Object as PropType<Log>,
    required: true,
  },
});

const showAllEntries = ref(false);

const sortedLogEntries = computed((): Array<TextLogEntry> => {
  const logEntries = sortBy(props.log.log_entries, 'created_at');

  if (isArrayOfTextLogEntries(logEntries)) {
    let logEntriesToShow;

    if (showAllEntries.value || logEntries.length <= 3) {
      logEntriesToShow = logEntries;
    } else {
      logEntriesToShow = logEntries.slice(logEntries.length - 3);
    }

    return logEntriesToShow.slice().reverse();
  } else {
    return [];
  }
});
</script>

<style lang="scss">
ol,
ul {
  $li-indent: 17px;

  &:not(:first-child) {
    margin-top: 16px;
  }

  li {
    &:not(:first-of-type) {
      margin-top: 0.5em;
    }

    display: block;
    margin-left: $li-indent;

    &::before {
      margin-left: -1 * $li-indent;
      position: absolute;
    }
  }
}

ol {
  counter-reset: item;

  li {
    &::before {
      content: counter(item) '. ';
      counter-increment: item;
    }
  }
}

ul {
  li {
    &::before {
      content: '– ';
    }
  }
}

blockquote {
  position: relative;
  padding-left: 20px;
}

blockquote::before {
  content: '';
  position: absolute;
  left: 0;
  top: 1.3em;
  bottom: 1.3em;
  width: 4px;
  background: #bbb;
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
    padding: 18px 10px;
    word-break: initial;
    white-space: pre-wrap;
    line-height: 1.3rem;
    text-align: center;
    vertical-align: middle;
    min-width: 140px;

    &.left-align {
      text-align: left;
    }

    p:not(:first-of-type) {
      margin-top: 16px;
    }
  }

  td:has(ol, li) {
    white-space: unset;
  }
}
</style>
