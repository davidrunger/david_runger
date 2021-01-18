<template lang='pug'>
Modal(
  name='log-selector'
  width='85%'
  maxWidth='400px'
  backgroundClass='bg-black'
)
  slot
    input.mb2(
      type='text'
      v-model='searchString'
      @keydown.enter='selectHighlightedLog'
      @keydown.up='decrementHighlightedLogIndex'
      @keydown.down='incrementHighlightedLogIndex'
      ref='log-search-input'
    )
    div
      .log-link-container(v-for='(log, index) in orderedMatches')
        router-link.log-link(
          :to='{ name: "log", params: { slug: log.slug }}'
          :class='{bold: (index === highlightedLogIndex)}'
        ) {{log.name}}
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import FuzzySet from 'fuzzyset.js';

import { on } from 'lib/event_bus';

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
        return this.logs;
      }

      const matches = this.fuzzySet.get(this.searchString, '', 0) || [];
      return matches.map(([_score, string]) => this.logs.find(log => log.name === string));
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
    this.unsubscribeFromRouteChanges = on('logs:route-changed', this.resetQuickSelector);
  },

  destroyed() {
    this.unsubscribeFromRouteChanges();
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
      } else {
        // wrap around from the top of the list to the bottom
        this.highlightedLogIndex = this.orderedMatches.length - 1;
      }
    },

    incrementHighlightedLogIndex() {
      if (this.highlightedLogIndex < this.orderedMatches.length - 1) {
        this.highlightedLogIndex++;
      } else {
        // wrap back around to the top of the list
        this.highlightedLogIndex = 0;
      }
    },

    selectHighlightedLog() {
      const highlightedLog = this.orderedMatches[this.highlightedLogIndex];
      this.selectLog(highlightedLog);
    },

    resetQuickSelector() {
      this.$store.commit('hideModal', { modalName: 'log-selector' });
      this.highlightedLogIndex = 0;
      this.searchString = '';
    },

    selectLog(log) {
      this.$router.push({ name: 'log', params: { slug: log.slug } });
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
          logSearchInput.focus();
        }
      });
    },
  },
};
</script>

<style lang='scss' scoped>
/deep/ input[type=text] {
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
