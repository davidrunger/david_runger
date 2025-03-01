<template lang="pug">
.relative.bg-white.flex.justify-center.p-4.scroll-mt-14(
  :id="section",
  :class="section",
  ref="root"
)
  section(:data-section="section")
    ScrollHook(:section="section")
    SectionHeader(v-if="!renderHeadingManually", :title="title")
    slot(:title="title")
</template>

<script setup lang="ts">
import ScrollHook from './ScrollHook.vue';
import SectionHeader from './SectionHeader.vue';

defineProps({
  renderHeadingManually: {
    type: Boolean,
    default: false,
  },
  section: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
});
</script>

<style lang="scss" scoped>
section {
  width: 100%;
  max-width: 850px;

  @media screen and (width >= 600px) {
    padding: 1rem 2rem 0;
  }
}
</style>
