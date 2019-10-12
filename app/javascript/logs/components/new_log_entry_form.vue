<template lang='pug'>
div
  vue-form.px1(@submit.prevent='postNewLogEntry' :state='formstate' :class='log.data_type')
    validate
      el-input.new-log-input.mb1(
        :placeholder='log.data_label'
        v-model='newLogEntryData'
        name='log.data_label'
        required
        ref='log-input'
        :type='inputType'
      )
    el-input.new-log-input.mb1(
      v-if='isDuration || isNumber'
      placeholder='Note (optional)'
      v-model='newLogEntryNote'
      type='text'
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
      if (this.isText) {
        return 'textarea';
      } else if (this.isNumber) {
        return 'number';
      } else {
        return 'text';
      }
    },

    isDuration() {
      return this.log.data_type === 'duration';
    },

    isNumber() {
      return this.log.data_type === 'number';
    },

    isText() {
      return this.log.data_type === 'text';
    },
  },

  data() {
    return {
      formstate: {},
      newLogEntryData: null,
      newLogEntryNote: null,
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
          newLogEntryNote: this.newLogEntryNote,
        },
      );
      this.newLogEntryData = null;
      this.newLogEntryNote = null;
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
/deep/ form.number,
form.duration {
  margin: 0 auto;
  max-width: 200px;
}
</style>
