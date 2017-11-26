<template lang="pug">
  div#groceries-app.sans-serif
    div#page.flex.vh-100
      Sidebar
      main.flex-1.bg-cover.overflow-auto
        LoggedInHeader
        Store(v-if='currentStore' :store='currentStore')
</template>

<script>
import { mapGetters } from 'vuex';
import LoggedInHeader from './components/logged_in_header.vue';
import Sidebar from './components/sidebar.vue';
import Store from './components/store.vue';

export default {
  components: {
    LoggedInHeader,
    Sidebar,
    Store,
  },

  computed: {
    ...mapGetters([
      'currentStore',
    ]),
  },
};
</script>

<style lang='scss' scoped>
main {
  background-image: url('~img/beach-background.jpg');
}
</style>
