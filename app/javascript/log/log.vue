<template lang='pug'>
div
  .center.mb1
    .pt1 {{bootstrap.current_user.email}}
    hr
    weight-section
    hr
    resistance-section
</template>

<script>
import ResistanceSection from './components/resistance_section.vue';
import WeightSection from './components/weight_section.vue';

export default {
  components: {
    ResistanceSection,
    WeightSection,
  },
};
</script>
