<template lang="pug">
h2.text-3xl.font-bold.my-4 {{ title }}
</template>

<script setup lang="ts">
import { string } from 'vue-types';

defineProps({
  title: string().isRequired,
});
</script>
