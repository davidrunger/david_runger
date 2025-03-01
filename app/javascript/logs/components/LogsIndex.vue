<template lang="pug">
section
  div
    .log-link-container.m-2.text-2xl(v-for="log in logs")
      router-link.log-link(:to="{ name: 'log', params: { slug: log.slug } }") {{ log.name }}
  hr.my-8.border-gray
  NewLogForm
</template>

<script setup lang="ts">
import { useTitle } from '@vueuse/core';
import { storeToRefs } from 'pinia';

import { useLogsStore } from '@/logs/store';

import NewLogForm from './NewLogForm.vue';

useTitle('Logs - David Runger');

const logsStore = useLogsStore();
const { logs } = storeToRefs(logsStore);
</script>

<style scoped>
hr {
  max-width: 400px;
}
</style>
