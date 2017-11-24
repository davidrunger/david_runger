<template lang="pug">
  div#groceries-app.sans-serif
    div#page.flex.vh-100
      Sidebar
      main.flex-1.bg-cover
        LoggedInHeader
        Store(v-if='currentStore' :store='currentStore')
</template>

<script>
import { mapState } from 'vuex';
import LoggedInHeader from './components/logged_in_header.vue';
import Sidebar from './components/sidebar.vue';
import Store from './store.vue';

export default {
  components: {
    LoggedInHeader,
    Sidebar,
    Store,
  },

  computed: {
    ...mapState([
      'currentStore',
    ]),
  },

  methods: {
    signOut() {
      this.$http.delete(this.$routes.destroy_user_session_path({ format: 'json' })).
        then(() => { window.location.assign(this.$routes.login_path()); });
    },
  },
};
</script>

<style lang='scss' scoped>
main {
  background-image: url('~img/beach-background.jpg');
}
</style>
