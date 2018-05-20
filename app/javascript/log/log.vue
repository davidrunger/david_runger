<template lang='pug'>
div
  .center.mb1
    .my1 {{bootstrap.current_user.email}}
    hr
    weight-section
</template>

<script>
import WeightSection from './components/weight_section.vue';

export default {
  components: {
    WeightSection,
  },
};
</script>

<style scoped>
div {
  font-family: sans-serif;
}
</style>
