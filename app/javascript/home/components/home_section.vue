<template lang='pug'>
.section-container.relative.bg-white.flex.justify-center(:class='section', ref='root')
  .anchor-target(:id='section')
  section.p3(:data-section='section')
    .js-scroll-hook.absolute(style='top: 25vh; bottom: 0;')
    Header(v-if='!renderHeadingManually' :title='title')
    slot(:title='title')
</template>

<script>
export const Header = {
  functional: true,
  render(h, context) {
    return h('h1', { class: 'h1 bold mb2' }, context.props.title);
  },
};

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
@import '~css/variables';

section {
  width: 850px;
}

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: $header-height;

  @media screen and (max-width: $small-screen-breakpoint) {
    bottom: 0;
  }
}
</style>
