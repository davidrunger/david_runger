<template lang='pug'>
div
  vue-form.px1(@submit.prevent='postNewLogEntry' :state='formstate')
    validate.mb1(
      v-for='log_input in log_inputs'
      :key='log_input.label'
    )
      el-input(
        :placeholder='log_input.label'
        v-model='newLogEntryData[log_input.label]'
        name='log_input.label'
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
      newLogEntryData: {},
    };
  },

  methods: {
    focusLogEntryInput() {
      setTimeout(() => {
        this.$refs['log-input'][0].focus();
      });
    },

    postNewLogEntry() {
      if (this.formstate.$invalid) return;

      this.$store.dispatch(
        'addLogEntry',
        {
          logId: this.log_id,
          newLogEntryData: this.newLogEntryData,
        },
      );
      this.newLogEntryData = {};
    },
  },

  mounted() {
    this.focusLogEntryInput();
  },

  props: {
    log_id: {
      type: Number,
      required: true,
    },
    log_inputs: {
      type: Array,
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
