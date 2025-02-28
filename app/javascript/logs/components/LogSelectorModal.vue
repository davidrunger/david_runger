<template lang="pug">
Modal(
  name='log-selector',
  width='85%',
  maxWidth='400px',
  backgroundClass='bg-black'
)
  input.mb-4(
    type='text',
    v-model='query',
    ref='logSearchInput',
    @keydown.enter='selectHighlightedLog',
    @keydown.up='onArrowUp',
    @keydown.down='onArrowDown'
  )
  div
    .log-link-container(v-for='log in rankedMatches')
      router-link.log-link(
        :to='{ name: "log", params: { slug: log.slug } }',
        :class='{ "font-bold": log === highlightedSearchable }'
      ) {{ log.name }}
</template>

<script setup lang="ts">
import { refDebounced } from '@vueuse/core';
import { storeToRefs } from 'pinia';
import { computed, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { useFuzzyTypeahead } from '@/lib/composables/useFuzzyTypeahead';
import { useSubscription } from '@/lib/composables/useSubscription';
import { useLogsStore } from '@/logs/store';
import type { Log } from '@/logs/types';
import { useModalStore } from '@/shared/modal/store';

const router = useRouter();
const logsStore = useLogsStore();
const { logs } = storeToRefs(logsStore);
const modalStore = useModalStore();
const query = ref('');
const queryDebounced = refDebounced(query, 60, { maxWait: 180 });
const logSearchInput = ref(null);
const { highlightedSearchable, onArrowDown, onArrowUp, rankedMatches } =
  useFuzzyTypeahead({
    searchables: logs,
    query: queryDebounced,
    fuseOptions: {
      keys: ['name'],
    },
  });

function resetQuickSelector() {
  modalStore.hideModal({ modalName: 'log-selector' });
  query.value = '';
}

useSubscription('logs:route-changed', resetQuickSelector);

const showingLogSelectorModal = computed(() => {
  return modalStore.showingModal({ modalName: 'log-selector' });
});

watch(showingLogSelectorModal, () => {
  // Wait a tick for input to render, then focus it. Autofocus only works once, so we need this.
  setTimeout(() => {
    if (logSearchInput.value) {
      (logSearchInput.value as HTMLInputElement).focus();
    }
  });
});

function selectHighlightedLog() {
  selectLog(highlightedSearchable.value);
}

function selectLog(log: Log) {
  router.push({ name: 'log', params: { slug: log.slug } });
  resetQuickSelector();
}
</script>

<style lang="scss" scoped>
:deep(input[type='text']) {
  max-width: 60%;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  box-sizing: border-box;
  color: #eee;
  display: inline-block;
  font-size: inherit;
  height: 40px;
  line-height: 40px;
  outline: 0;
  padding: 0 15px;
  transition: border-color 0.2s cubic-bezier(0.645, 0.045, 0.355, 1);
}
</style>
