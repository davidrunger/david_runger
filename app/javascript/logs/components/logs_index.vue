<template lang='pug'>
section
  div
    .log-link-container.m1.h2(v-for='log in logs')
      router-link.log-link(:to='{ name: "log", params: { slug: log.slug }}') {{log.name}}
  hr.my3.border-gray
  NewLogForm
</template>

<script lang='ts'>
import { mapState } from 'pinia';
import { useTitle } from '@vueuse/core';

import { useLogsStore } from '@/logs/store';
import NewLogForm from './new_log_form.vue';

export default {
  components: {
    NewLogForm,
  },

  computed: {
    ...mapState(useLogsStore, [
      'logs',
    ]),
  },

  setup() {
    useTitle('Logs - David Runger');
  },
};
</script>

<style scoped>
hr {
  max-width: 400px;
}
</style>
