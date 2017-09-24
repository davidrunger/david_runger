<template lang='pug'>
.section-container.relative.overflow-hidden(ref='root')
  .background-container(ref='background-container')
  .anchor-target(:id='section')
  section(:data-section='section')
    h2.font-size-3
      span {{title}}
    slot
</template>

<script>
import Trianglify from 'trianglify';

export default {
  mounted() {
    const pattern = Trianglify({
      x_colors: this.colorPalette,
      cell_size: 100,
      variance: 0.7,
      height: this.$refs.root.offsetHeight * 1.5,
      width: window.screen.width * 2,
    });
    this.$refs['background-container'].prepend(pattern.canvas());
  },

  props: {
    backgroundSeed: {},
    colorPalette: {},
    section: {},
    title: {},
  },
};
</script>

<style lang='scss' scoped>
@import '~css/variables';

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: 35px;
}

.section-container {
  border-top: 20px solid black;
}

[data-section=about] {
  height: 400px;
}

.about-image {
  max-height: 250px;
}

section {
  padding: 30px;
  max-width: 850px;
  margin: 0 auto;

  h2 {
    padding-bottom: 30px;

    span {
      border-bottom: 2px solid $black-lighter;
      padding-bottom: 5px;
    }
  }

  p {
    padding-bottom: 25px;
    font-size: 16px;
    line-height: 24px;
  }
}

.background-container {
  position: absolute;
  z-index: -1;
}
</style>
