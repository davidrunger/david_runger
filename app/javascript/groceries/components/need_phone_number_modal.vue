<template lang="pug">
Modal(name='set-phone-number' width='85%', maxWidth='400px')
  slot
    h2.bold.mb2 We need your phone number, first
    p Click #[a(:href='editUserPath') here] to enter your phone number.
    div.flex.justify-around.mt2
      el-button(
        @click="$store.commit('hideModal', { modalName: 'set-phone-number' })"
        type='text'
      ) Cancel
</template>

<script>
import { mapState } from 'vuex';

export default {
  computed: {
    ...mapState([
      'current_user',
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
