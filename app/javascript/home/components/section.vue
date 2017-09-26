<template lang='pug'>
.section-container.relative.overflow-hidden(ref='root')
  .anchor-target(:id='section')
  section(:data-section='section')
    h2.font-size-3
      span {{title}}
    slot
</template>

<script>
export default {
  props: {
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
</style>
