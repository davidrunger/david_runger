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

<script setup lang="ts">
import { ElButton, ElInput, ElOption, ElSelect } from 'element-plus';
import { storeToRefs } from 'pinia';
import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';

import { bootstrap } from '@/lib/bootstrap';
import { useLogsStore } from '@/logs/store';
import type { Bootstrap, LogInput } from '@/logs/types';

const router = useRouter();
const logsStore = useLogsStore();
const newLog = ref(newLogGenerator());

const { postingLog } = storeToRefs(logsStore);

const logInputTypes = computed((): Array<LogInput> => {
  return (bootstrap as Bootstrap).log_input_types;
});

async function createLog() {
  const log = await logsStore.createLog({ log: newLog.value });
  newLog.value = newLogGenerator();
  router.push({ name: 'log', params: { slug: log.slug } });
}

function newLogGenerator() {
  return {
    data_label: '',
    data_type: '',
    description: '',
    name: '',
  };
}
</script>
