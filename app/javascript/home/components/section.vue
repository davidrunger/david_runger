<template lang='pug'>
.section-container.relative.overflow-hidden(ref='root')
  .background-container(ref='background-container')
  section(:id='section', :data-section='section')
    h2.font-size-3 {{title}}
    slot
</template>

<script>
import Trianglify from 'trianglify';

export default {
  mounted() {
    var pattern = Trianglify({
      x_colors: this.colorPalette,
      cell_size: 100,
      variance: .7,
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
