<template lang="pug">
el-menu
  el-sub-menu(index='1')
    template(v-slot:title) Account
    el-menu-item.email(
      index='1-1'
      :disabled='true'
    ) {{currentUser.email}}
    a(:href="$routes.edit_user_path(currentUser)")
      el-menu-item(index='1-2') Account Settings
    a.js-link(@click='signOut')
      el-menu-item(index='1-3') Sign Out
</template>

<script lang="ts">
import { defineComponent } from 'vue';

import { Bootstrap } from '@/groceries/types';
import { signOut } from '@/lib/sign_out';

export default defineComponent({
  data() {
    return {
      currentUser: (this.$bootstrap as Bootstrap).current_user,
    };
  },

  methods: {
    signOut,
  },
});
</script>

<style lang="scss" scoped>
.email {
  font-size: 10px;
  height: 30px;
}

:deep(.el-sub-menu .el-menu-item.el-menu-item.el-menu-item) {
  @media screen and (width <= 500px) {
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
