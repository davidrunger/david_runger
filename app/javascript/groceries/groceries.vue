<template lang="pug">
div#groceries-app
  div#page.flex.dvh-100
    Sidebar
    main.flex-1.bg-cover
      Store(
        v-if='currentStore'
        :store='currentStore'
      )
</template>

<script>
import { mapState } from 'pinia';
import { useGroceriesStore } from '@/groceries/store';
import Sidebar from './components/sidebar.vue';
import Store from './components/store.vue';

export default {
  components: {
    Sidebar,
    Store,
  },

  computed: {
    ...mapState(useGroceriesStore, [
      'currentStore',
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

<style lang='scss'>
#groceries-app {
  font-size: 0.95rem;
}

main {
  background-image: url("../../assets/images/beach-background.webp");
  z-index: 5;
}

.toastify {
  &.error {
    background: #d42b2b;
  }

  &.success {
    background: #219b21;
  }
}

.icon-tabler {
  vertical-align: bottom;
}
</style>
