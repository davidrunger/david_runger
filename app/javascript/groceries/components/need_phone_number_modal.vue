<template lang="pug">
Modal(v-if="showNeedPhoneNumberModal" width='85%', maxWidth='400px')
  slot
    h2.bold.fonst-size-1.mb2 We need your phone number, first
    p Click #[a(:href='editUserPath') here] to enter your phone number.
    div.flex.justify-around.mt2
      el-button(
        @click="$store.commit('setShowNeedPhoneNumberModal', { value: false })"
        type='text'
      ) Cancel
</template>

<script>
import { mapState } from 'vuex';

export default {
  computed: {
    ...mapState([
      'current_user',
      'showNeedPhoneNumberModal',
    ]),

    editUserPath() {
      return this.$routes.edit_user_path({
        id: this.current_user.id,
        redirect_to: this.$routes.groceries_path(),
        _options: {}, // providing `_options` seems to be necessary to put query params in the path
      });
    },
  },
};
</script>
