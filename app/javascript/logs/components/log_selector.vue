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
    ul
      li.log-link-container(v-for='(logName, index) in orderedMatches')
        a.log-link.js-link(
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
