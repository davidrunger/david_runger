<template lang='pug'>
div
  .center.mb1
    .h5.gray.pt1 {{bootstrap.current_user.email}}
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
