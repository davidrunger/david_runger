<template lang='pug'>
.section-container.relative.bg-white.flex.justify-center(:class='section', ref='root')
  .anchor-target(:id='section')
  section.py3.px1(:data-section='section')
    .js-scroll-hook.absolute
    Header(v-if='!renderHeadingManually', :title='title')
    slot(:title='title')
</template>

<script>
import { h } from 'vue';

export const Header = props => h('h1', { class: 'h1 bold mt0 mb3' }, props.title);
Header.props = ['title'];

export default {
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

  components: {
    Header,
  },
};
</script>

<style lang='scss' scoped>
@import "css/variables";

section {
  width: 100%;
  max-width: 850px;

  @media screen and (min-width: 600px) {
    padding: var(--space-3);
  }
}

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: $header-height;
}

.js-scroll-hook {
  top: 25vh;
  bottom: 0;
}
</style>
