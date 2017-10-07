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

$color-1: #f7e4de;
$color-2: #eeeeee;
$color-3: #cddbdb;

.about {
  position: relative;
}

.about:after {
  content : "";
  display: block;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  opacity : 0.4;
  background-image: url('~img/coastline.jpg');
  background-repeat: no-repeat;
  background-size: cover;
  z-index: -1;
}

.skills { background: #ffffff; }
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

section {
  padding: 40px;
  max-width: 850px;
  margin: 0 auto;
  color: $ivory-black;

  h2 {
    padding-bottom: 30px;
    font-weight: bold;
  }
}

.about {
  line-height: 24px;

  p {
    padding-bottom: 25px;
    font-size: 16px;
  }
}
</style>
