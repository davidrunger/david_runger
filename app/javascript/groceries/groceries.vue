<template lang="pug">
div#groceries-app
  div#page.flex.vh-100
    Sidebar
    main.flex-1.bg-cover.overflow-auto
      Store(v-if='currentStore' :store='currentStore')
</template>

<script>
import { mapGetters } from 'vuex';
import Sidebar from './components/sidebar.vue';
import Store from './components/store.vue';

export default {
  components: {
    Sidebar,
    Store,
  },

  computed: {
    ...mapGetters([
      'currentStore',
      'debouncingOrWaitingOnNetwork',
    ]),
  },

  created() {
    window.addEventListener('beforeunload', this.warnIfRequestPending);
  },

  methods: {
    warnIfRequestPending(event) {
      if (this.debouncingOrWaitingOnNetwork) {
        event.preventDefault();
        // Chrome requires returnValue to be set
        // https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
        event.returnValue = '';
      }
    },
  },

  props: {},
};
</script>

<style lang='scss' scoped>
#groceries-app {
  font-size: 0.95rem;
}

main {
  background-image: url('../../assets/images/beach-background.jpg');
}

html.webp {
  main {
    background-image: url('../../assets/images/beach-background.webp');
  }
}
</style>
