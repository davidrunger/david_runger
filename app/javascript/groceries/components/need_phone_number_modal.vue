<template lang="pug">
Modal(name='set-phone-number' width='85%', maxWidth='400px')
  slot
    h2.bold.mb2 We need your phone number, first
    el-input(
      v-model='phone'
      placeholder='123-555-1234'
    )
    div.flex.justify-around.mt2
      el-button(
        @click='savePhoneAndSendSms'
        type='primary'
        plain
      ) Save phone # and send text
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
  },

  data() {
    return {
      phone: null,
    };
  },

  methods: {
    savePhoneAndSendSms() {
      this.$http.patch(
        this.$routes.api_user_path({ id: this.bootstrap.current_user.id }),
        { user: { phone: this.phone } },
      ).then(({ data }) => {
        this.current_user.phone = data.phone;
        this.$store.commit('hideModal', { modalName: 'set-phone-number' });
        this.$emit('send-text-message');
      });
    },
  },
};
</script>
