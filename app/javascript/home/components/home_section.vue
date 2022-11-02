<template lang='pug'>
.section-container.relative.bg-white.flex.justify-center.p2(:class='section', ref='root')
  .anchor-target(:id='section')
  section(:data-section='section')
    ScrollHook(:section='section')
    SectionHeader(v-if='!renderHeadingManually', :title='title')
    slot(:title='title')
</template>

<script>
import { h } from 'vue';

import ScrollHook from './scroll_hook.vue';

export const SectionHeader = props => h('h1', { class: 'h1 bold mt0 my2' }, props.title);
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
      required: false,
    },
    title: {
      type: String,
      required: false,
    },
  },
};
</script>

<style lang='scss' scoped>
@import "css/variables";

section {
  width: 100%;
  max-width: 850px;

  @media screen and (min-width: 600px) {
    padding: var(--space-2) var(--space-3) 0 var(--space-3);
  }
}

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: $header-height;
}
</style>
