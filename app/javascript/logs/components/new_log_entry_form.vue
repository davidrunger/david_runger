<template lang='pug'>
div
  vue-form.px1(@submit.prevent='postNewLogEntry' :state='formstate')
    validate.mb1
      el-input.new-log-input(
        :placeholder='log.data_label'
        v-model='newLogEntryData'
        name='log.data_label'
        required
        ref='log-input'
        :type='inputType'
      )
    el-input(
      type='submit'
      value='Add'
      :disabled='formstate.$invalid'
    )
</template>

<script>
export default {
  computed: {
    inputType() {
      if (['text'].indexOf(this.log.data_type) >= 0) {
        return 'textarea';
      } else if (['number'].indexOf(this.log.data_type) >= 0) {
        return 'number';
      } else {
        return 'text';
      }
    },
  },

  data() {
    return {
      formstate: {},
      newLogEntryData: null,
    };
  },

  methods: {
    focusLogEntryInput() {
      setTimeout(() => {
        this.$refs['log-input'].focus();
      });
    },

    postNewLogEntry() {
      if (this.formstate.$invalid) return;

      this.$store.dispatch(
        'addLogEntry',
        {
          logId: this.log.id,
          newLogEntryData: this.newLogEntryData,
        },
      );
      this.newLogEntryData = null;
    },
  },

  mounted() {
    this.focusLogEntryInput();
  },

  props: {
    log: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang='scss' scoped>
/deep/ .new-log-input {
  textarea {
    height: 5rem;
  }
}
</style>
