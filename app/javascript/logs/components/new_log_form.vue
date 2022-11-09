<template lang='pug'>
div
  .h2.my2 New Log
  .flex.justify-center.mb1
    div(style='width: 400px')
      form.px1(@submit.prevent='createLog')
        .mb1
          el-input(
            placeholder='Name'
            v-model='newLog.name'
            name='newLog.name'
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
          )
        .mb1
          el-select(
            placeholder='Type'
            v-model='newLog.data_type'
            name='newLog.data_type'
          )
            el-option(
              v-for='dataType in $bootstrap.log_input_types'
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
import { mapState } from 'pinia';
import { useLogsStore } from '@/logs/store';

export default {
  computed: {
    ...mapState(useLogsStore, [
      'postingLog',
    ]),
  },

  data() {
    return {
      logsStore: useLogsStore(),
      newLog: {
        data_label: '',
        data_type: '',
        description: '',
        name: '',
      },
    };
  },

  methods: {
    createLog() {
      this.logsStore.createLog({ log: this.newLog }).
        then((log) => {
          this.newLog = {};
          this.$router.push({ name: 'log', params: { slug: log.slug } });
        });
    },
  },
};
</script>
