<template lang='pug'>
.section-container.relative.bg-white.flex.justify-center(:class='section', ref='root')
  .anchor-target(:id='section')
  section.p3(:data-section='section')
    .js-scroll-hook.absolute(style='top: 25vh; bottom: 0;')
    h2.h1.bold.mb2 {{title}}
    slot
</template>

<script>
export default {
  props: {
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
@import '~css/variables';

section {
  width: 850px;
}

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: $header-height;
}
</style>
