<template lang="pug">
.section-container.relative.bg-white.flex.justify-center.p-4(:class='section', ref='root')
  .anchor-target(:id='section')
  section(:data-section='section')
    ScrollHook(:section='section')
    SectionHeader(v-if='!renderHeadingManually', :title='title')
    slot(:title='title')
</template>

<script lang="ts">
import { h } from 'vue';

import ScrollHook from './scroll_hook.vue';

export const SectionHeader = (props: { title?: string }) =>
  h('h1', { class: 'text-3xl font-bold my-4' }, props.title);
SectionHeader.props = ['title'];

export default {
  components: {
    ScrollHook,
    SectionHeader,
  },

  props: {
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
      required: false,
    },
  },
};
</script>

<style lang="scss" scoped>
@import 'css/variables';

section {
  width: 100%;
  max-width: 850px;

  @media screen and (width >= 600px) {
    padding: 1rem 2rem 0;
  }
}

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: $header-height;
}
</style>
