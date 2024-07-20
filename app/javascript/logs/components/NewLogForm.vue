<template lang="pug">
div
  .h2.my-8 New Log
  .flex.justify-center.mb-2
    div(style='width: 400px')
      form.px-2(@submit.prevent='createLog')
        .mb-2
          el-input(
            placeholder='Name'
            v-model='newLog.name'
            name='newLog.name'
          )
        el-input.mb-2(
          type='textarea'
          placeholder='Details/Description (optional)'
          v-model='newLog.description'
          name='newLog.description'
        )
        .mb-2
          el-input(
            placeholder='Label (e.g. Weight, Run time, etc)'
            v-model='newLog.data_label'
            name='newLog.data_label'
          )
        .mb-2
          el-select(
            placeholder='Type'
            v-model='newLog.data_type'
            name='newLog.data_type'
          )
            el-option(
              v-for='dataType in logInputTypes'
              :key='dataType.data_type'
              :label='dataType.label'
              :value='dataType.data_type'
            )
        el-button(
          native-type='submit'
          :disabled='postingLog'
        ) Create
</template>

<script lang="ts">
import { mapState } from 'pinia';
import { defineComponent } from 'vue';

import { useLogsStore } from '@/logs/store';
import { Bootstrap, LogInputType } from '@/logs/types';

export default defineComponent({
  data() {
    return {
      logsStore: useLogsStore(),
      newLog: this.newLogGenerator(),
    };
  },

  computed: {
    ...mapState(useLogsStore, ['postingLog']),

    logInputTypes(): Array<LogInputType> {
      return (this.$bootstrap as Bootstrap).log_input_types;
    },
  },

  methods: {
    async createLog() {
      const log = await this.logsStore.createLog({ log: this.newLog });
      this.newLog = this.newLogGenerator();
      this.$router.push({ name: 'log', params: { slug: log.slug } });
    },

    newLogGenerator() {
      return {
        data_label: '',
        data_type: '',
        description: '',
        name: '',
      };
    },
  },
});
</script>
