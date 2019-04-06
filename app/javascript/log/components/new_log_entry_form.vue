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
      :disabled='postingLogEntry || formstate.$invalid'
    )
</template>

<script>
export default {
  data() {
    return {
      formstate: {},
      newLogEntryData: {},
      postingLogEntry: false,
    };
  },

  methods: {
    postNewLogEntry() {
      if (this.formstate.$invalid) return;

      this.postingLogEntry = true;

      const payload = {
        log_entry: {
          data: this.newLogEntryData,
          log_id: this.log_id,
        },
      };
      this.$http.post(this.$routes.api_log_entries_path(), payload).then(() => {
        this.newLogEntryData = {};
        this.postingLogEntry = false;
        window.location.reload();
      });
    },
  },

  mounted() {
    setTimeout(() => {
      this.$refs['log-input'][0].focus();
    });
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
};
</script>
