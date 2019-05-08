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
import { mapGetters, mapState } from 'vuex';
import FuzzySet from 'fuzzyset.js';

const ALL_LOGS = 'All logs';

export default {
  computed: {
    ...mapGetters([
      'logByName',
    ]),

    ...mapState([
      'logs',
    ]),

    logNames() {
      return this.logs.map(log => log.name);
    },

    orderedMatches() {
      if (!this.searchString) {
        return [ALL_LOGS].concat(this.logNames);
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
      const highlightedLogName = this.orderedMatches[this.highlightedLogIndex];
      if (highlightedLogName) {
        this.selectLog(highlightedLogName);
      }
    },

    selectLog(logName) {
      if (logName === ALL_LOGS) {
        this.$router.push({ name: 'logs-index' });
      } else {
        const log = this.logByName({ logName });
        if (log) {
          this.$router.push({ name: 'log', params: { slug: log.slug }});
        }
      }
      this.$store.commit('hideModal', { modalName: 'log-selector' });
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
