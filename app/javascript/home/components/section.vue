<template lang='pug'>
.section-container.relative.overflow-hidden(:class='section', ref='root')
  .anchor-target(:id='section')
  section(:data-section='section')
    h2.font-size-3 {{title}}
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

$ivory-black: #131920;

$color-1: #fcf5f3;
$color-2: #fbfbfb;
$color-3: #edeafa;

.about { background: $color-1; }
.skills { background: $color-2; }
.projects { background: $color-3; }
.resume { background: $color-2; }
.contact { background: $color-1; }

// semi-hacky way to make scroll position account for header space
.anchor-target {
  position: relative;
  bottom: 35px;
}

[data-section=about] {
  height: 500px;
}

.about-image {
  max-width: 100%;
  box-shadow: $gray-light 0px 2px 5px;
  margin-right: 30px;
}

section {
  padding: 40px;
  max-width: 850px;
  margin: 0 auto;
  color: $ivory-black;

  h2 {
    padding-bottom: 30px;
  }

  p, img {
    margin-left: 30px;
  }

  p {
    padding-bottom: 25px;
    font-size: 16px;
    line-height: 24px;
  }
}
</style>
