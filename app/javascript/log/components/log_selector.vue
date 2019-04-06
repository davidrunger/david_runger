<template lang='pug'>
Modal(name='log-selector' width='85%', maxWidth='400px')
  slot
    input(
      type='text'
      v-model='searchString'
      @keydown.enter='selectHighlightedLog'
      @keydown.up='decrementHighlightedLogIndex'
      @keydown.down='incrementHighlightedLogIndex'
      ref='log-search-input'
    )
    div(v-for='(logName, index) in orderedMatches')
      a.js-link(
        @click='selectLog(logName)'
        :class='{bold: (index === highlightedLogIndex)}'
      ) {{logName}}
</template>

<script>
import { mapState } from 'vuex';
import FuzzySet from 'fuzzyset.js';

export default {
  computed: {
    ...mapState([
      'logs',
    ]),

    logNames() {
      return this.logs.map(log => log.name);
    },

    orderedMatches() {
      if (!this.searchString) {
        return this.logNames;
      }

      const matches = this.fuzzySet.get(this.searchString, '', 0) || [];
      return matches.map(([_score, string]) => string);
    },

    showingLogSelector() {
      return this.$store.getters.showingModal({ modalName: 'log-selector' });
    },
  },

  created() {
    this.fuzzySet = FuzzySet();
    this.logNames.forEach(logName => {
      this.fuzzySet.add(logName);
    });
  },

  data() {
    return {
      highlightedLogIndex: 0,
      searchString: '',
    };
  },

  methods: {
    decrementHighlightedLogIndex() {
      if (this.highlightedLogIndex > 0) {
        this.highlightedLogIndex--;
      }
    },

    incrementHighlightedLogIndex() {
      if (this.highlightedLogIndex < this.orderedMatches.length) {
        this.highlightedLogIndex++;
      }
    },

    selectHighlightedLog() {
      const highlightedLogNate = this.orderedMatches[this.highlightedLogIndex];
      if (highlightedLogNate) {
        this.selectLog(highlightedLogNate);
      }
    },

    selectLog(logName) {
      this.$store.dispatch('selectLog', { logName });
      this.highlightedLogIndex = 0;
      this.searchString = '';
    },
  },

  watch: {
    // reset highlightedLogIndex to 0 whenever the matched logs changes (e.g. the user types more)
    orderedMatches() {
      this.highlightedLogIndex = 0;
    },

    showingLogSelector() {
      // wait a tick for input to render, then focus it
      setTimeout(() => {
        const logSearchInput = this.$refs['log-search-input'];
        if (logSearchInput) {
          logSearchInput.focus()
        }
      });
    },
  },
};
</script>
