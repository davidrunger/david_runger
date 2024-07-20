<template lang="pug">
.p-8
  h1.text-center Welcome to Vue, {{ name }}!
</template>

<script setup lang="ts">
const name = 'David';
</script>

<style scoped>
h1 {
  color: blue;
}
</style>
