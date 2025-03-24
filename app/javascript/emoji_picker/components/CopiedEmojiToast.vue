<template lang="pug">
div
  span.align-middle.font-bold Copied:
  |
  |
  span.align-middle.text-4xl {{ symbol }}
</template>

<script setup lang="ts">
defineProps({
  symbol: {
    required: true,
    type: String,
  },
});
</script>
