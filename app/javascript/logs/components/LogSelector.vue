<template lang="pug">
Modal(
  name='log-selector'
  width='85%'
  maxWidth='400px'
  backgroundClass='bg-black'
)
  input.mb-4(
    type='text'
    v-model='query'
    ref='log-search-input'
    @keydown.enter='selectHighlightedLog'
    @keydown.up='onArrowUp'
    @keydown.down='onArrowDown'
  )
  div
    .log-link-container(v-for='log in rankedMatches')
      router-link.log-link(
        :to='{ name: "log", params: { slug: log.slug }}'
        :class='{"font-bold": (log === highlightedSearchable)}'
      ) {{log.name}}
</template>

<script lang="ts">
import { refDebounced } from '@vueuse/core';
import { storeToRefs } from 'pinia';
import { ref } from 'vue';

import { useFuzzyTypeahead } from '@/lib/composables/fuzzy_typeahead';
import { useSubscription } from '@/lib/composables/use_subscription';
import { useLogsStore } from '@/logs/store';
import { useModalStore } from '@/shared/modal/store';

import { Log } from '../types';

export default {
  computed: {
    showingLogSelector(): boolean {
      return this.modalStore.showingModal({ modalName: 'log-selector' });
    },
  },

  methods: {
    selectHighlightedLog() {
      this.selectLog(this.highlightedSearchable);
    },

    selectLog(log: Log) {
      this.$router.push({ name: 'log', params: { slug: log.slug } });
    },
  },

  setup() {
    const logsStore = useLogsStore();
    const { logs } = storeToRefs(logsStore);
    const modalStore = useModalStore();
    const query = ref('');
    const queryDebounced = refDebounced(query, 60, { maxWait: 180 });
    const { highlightedSearchable, onArrowDown, onArrowUp, rankedMatches } =
      useFuzzyTypeahead({
        searchables: logs.value,
        query: queryDebounced,
        propertyToSearch: 'name',
      });

    function resetQuickSelector() {
      modalStore.hideModal({ modalName: 'log-selector' });
      query.value = '';
    }

    useSubscription('logs:route-changed', resetQuickSelector);

    return {
      modalStore,
      query,
      highlightedSearchable,
      onArrowDown,
      onArrowUp,
      rankedMatches,
    };
  },

  watch: {
    showingLogSelector() {
      // Wait a tick for input to render, then focus it. Autofocus only works once, so we need this.
      setTimeout(() => {
        const logSearchInput = this.$refs['log-search-input'];
        if (logSearchInput) {
          (logSearchInput as HTMLInputElement).focus();
        }
      });
    },
  },
};
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
