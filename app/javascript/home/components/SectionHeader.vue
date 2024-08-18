<template lang="pug">
h2.text-3xl.font-bold.my-4 {{ title }}
</template>

<script setup lang="ts">
defineProps({
  title: {
    type: String,
    required: true,
  },
});
</script>
