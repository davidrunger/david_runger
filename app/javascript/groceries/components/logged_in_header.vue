<template lang="pug">
el-menu.center
  el-sub-menu(index='1')
    template(v-slot:title) Account
    el-menu-item.email(
      index='1-1'
      :disabled='true'
    ) {{$bootstrap.current_user.email}}
    a(:href="$routes.edit_user_path($bootstrap.current_user)")
      el-menu-item(index='1-2') Account Settings
    a.js-link(@click='signOut()')
      el-menu-item(index='1-3') Sign Out
</template>

<script>
import signOutMixin from '@/lib/mixins/sign_out_mixin';

export default {
  mixins: [signOutMixin],
};
</script>

<style lang='scss' scoped>
.email {
  font-size: 10px;
  height: 30px;
}

:deep(.el-sub-menu .el-menu-item.el-menu-item.el-menu-item) {
  @media screen and (max-width: 500px) {
    padding-left: 15px;
  }
}

:deep(.el-sub-menu .el-icon.el-sub-menu__icon-arrow) {
  right: 10px;
  width: initial;
}

.el-menu {
  background-color: #e1eeff;
  border: none;
}

:deep(.el-sub-menu.is-opened .el-sub-menu__title) {
  background-color: #d1e7ff;
}

:deep(.el-menu),
:deep(.el-sub-menu__title i) {
  color: #111;
}

:deep(.el-menu--inline) {
  background-color: rgba(255, 255, 255, 90%);
}

:deep(.el-menu-item.is-disabled) {
  cursor: default;
}
</style>
