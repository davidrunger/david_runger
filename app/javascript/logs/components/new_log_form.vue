<template lang='pug'>
div
  .h2.my2 New Log
  .flex.justify-center.mb1
    div(style='width: 400px')
      form.px1(@submit.prevent='postNewLog')
        .mb1
          el-input(
            placeholder='Name'
            v-model='newLog.name'
            name='newLog.name'
            required
          )
        el-input.mb1(
          type='textarea'
          placeholder='Details/Description'
          v-model='newLog.description'
          name='newLog.description'
        )
        .mb1
          el-input(
            placeholder='Label'
            v-model='newLog.data_label'
            name='newLog.data_label'
            required
          )
        .mb1
          el-select(
            placeholder='Type'
            v-model='newLog.data_type'
            name='newLog.data_type'
            required
          )
            el-option(
              v-for='dataType in bootstrap.log_input_types'
              :key='dataType.data_type'
              :label='dataType.label'
              :value='dataType.data_type'
            )
        el-button(
          native-type='submit'
          :disabled='postingLog'
        ) Create
</template>

<script>
export default {
  data() {
    return {
      newLog: {
        data_label: '',
        data_type: '',
        description: '',
        name: '',
      },
      postingLog: false,
    };
  },

  methods: {
    postNewLog() {
      this.postingLog = true;

      this.$http.post(this.$routes.api_logs_path(), { log: this.newLog }).then(() => {
        this.newLog = {};
        this.postingLog = false;
        window.location.reload();
      });
    },
  },
};
</script>
