<template lang='pug'>
div
  div {{bootstrap.current_user.email}}
  vue-form(@submit.prevent='postWeightLog' :state='formstate')
    validate
      el-input(
        placeholder='Weight'
        type='number'
        v-model='newWeightLogWeight'
        name='newWeightLogWeight'
        required
      )
    el-input(
      value='Add'
      type='submit'
      :disabled='formstate.$invalid'
    )
</template>

<script>
export default {
  data() {
    return {
      formstate: {},
      newWeightLogWeight: '',
    };
  },

  methods: {
    postWeightLog() {
      if (this.formstate.$invalid) return;

      const payload = {
        weight_log: {
          weight: this.newWeightLogWeight,
        },
      };
      this.$http.post(this.$routes.api_weight_logs_path(), payload).then(() => {
        this.newWeightLogWeight = '';
      });
    },
  },
};
</script>

<style scoped>
div {
  font-family: sans-serif;
}
</style>
