<template lang="pug">
  div#groceries-app.sans-serif
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
    ]),
  },

  props: {},
};
</script>

<style lang='scss' scoped>
#groceries-app {
  font-size: 0.95rem;
}

main {
  background-image: url('~img/beach-background.jpg');
}

html.webp {
  main {
    background-image: url('~img/beach-background.webp');
  }
}
</style>
