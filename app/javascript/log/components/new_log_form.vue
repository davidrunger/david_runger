<template lang='pug'>
div
  .h2.my2 New Log
  .flex.justify-center.mb1
    div(style='width: 400px')
      vue-form.px1(@submit.prevent='postNewLog' :state='formstate')
        validate.mb1
          el-input(
            placeholder='Name'
            v-model='newLogName'
            name='newLogName'
            required
          )
        el-input.mb1(
          type='textarea'
          placeholder='Details/Description'
          v-model='newLogDescription'
          name='newLogDescription'
        )
        validate.mb1(
          v-for='(logInput, index) in newLogInputs'
          :key='index'
        )
          el-input.mb1(
            placeholder='Label'
            v-model='logInput.label'
            name='logInput.log_input_id'
            required
          )
          el-select(
            placeholder='Type'
            v-model='logInput.public_type'
            name='logInput.public_type'
            required
          )
            el-option(
              v-for='inputType in bootstrap.log_input_types'
              :key='inputType.public_type'
              :label='inputType.label'
              :value='inputType.public_type'
            )
        el-input(
          type='submit'
          value='Create'
          :disabled='postingLog || formstate.$invalid'
        )
</template>

<script>
export default {
  data() {
    return {
      formstate: {},
      newLogDescription: '',
      newLogName: '',
      newLogInputs: [{}],
      postingLog: false,
    };
  },

  methods: {
    postNewLog() {
      if (this.formstate.$invalid) return;

      this.postingLog = true;

      const payload = {
        log: {
          description: this.newLogDescription,
          name: this.newLogName,
          log_inputs_attributes: this.newLogInputs.map((input, i) => {
            input.index = i;
            return input;
          }),
        },
      };
      this.$http.post(this.$routes.api_logs_path(), payload).then(() => {
        this.newLogName = '';
        this.postingLog = false;
        window.location.reload();
      });
    },
  },
};
</script>
