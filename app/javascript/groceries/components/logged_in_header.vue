<template lang="pug">
.right-align.bg-white.bg-lighten-4.pr2
  el-dropdown(
    :hide-timeout=50
    :show-timeout=0
    placement='bottom-end'
  )
    .user-email {{ bootstrap.current_user.email }} #[i.fa.fa-angle-down]
    el-dropdown-menu(slot='dropdown')
      a(:href="$routes.edit_user_path(bootstrap.current_user)")
        el-dropdown-item Edit Account
      a.js-link(@click='signOut()')
        el-dropdown-item(divided :command='signOut') Sign Out
</template>

<script>
export default {
  methods: {
    signOut() {
      this.$http.delete(this.$routes.destroy_user_session_path({ format: 'json' })).
        then(() => { window.location.assign(this.$routes.login_path()); });
    },
  },
};
</script>

<style lang='scss' scoped>
.user-email {
  line-height: 30px;
}
</style>
