<template lang='pug'>
div
  vue-form.px1(@submit.prevent='postNewLogEntry' :state='formstate')
    validate.mb1
      el-input(
        :placeholder='log.data_label'
        v-model='newLogEntryData'
        name='log.data_label'
        required
        ref='log-input'
      )
    el-input(
      type='submit'
      value='Add'
      :disabled='formstate.$invalid'
    )
</template>

<script>
export default {
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

  watch: {
    $route() {
      this.focusLogEntryInput();
    },
  },
};
</script>
