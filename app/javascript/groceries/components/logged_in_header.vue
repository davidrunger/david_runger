<template lang="pug">
el-menu.center
  el-submenu(index='1')
    template(v-slot:title) {{bootstrap.current_user.email}}
    a(:href="$routes.edit_user_path(bootstrap.current_user)")
      el-menu-item(index='1-1') Account Settings
    a.js-link(@click='signOut()')
      el-menu-item(index='1-2') Sign Out
</template>

<script>
import signOutMixin from 'lib/mixins/sign_out_mixin';

export default {
  mixins: [signOutMixin],
};
</script>

<style lang='scss' scoped>
.user-email {
  line-height: 30px;
}

.el-menu {
  background-color: #e1eeff;
  border: none;
}

:deep(.el-submenu.is-opened .el-submenu__title) {
  background-color: #d1e7ff;
}

:deep(.el-menu),
:deep(.el-submenu__title i) {
  color: #111;
}

:deep(.el-menu--inline) {
  background-color: rgba(255, 255, 255, 0.9);
}
</style>
