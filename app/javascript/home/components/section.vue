<template lang='pug'>
div
  hr(:id='section', :class='{"visibility-hidden": hideHr}')
  section(:data-section='section')
    h2.font-size-3 {{title}}
    slot
</template>

<script>
import Trianglify from 'trianglify';

export default {
  created() {
    console.log(Trianglify);
  },

  props: {
    hideHr: { default: false },
    section: {},
    title: {},
  },
};
</script>

<style lang='scss' scoped>
section {
  padding: 30px 0;

  h2 {
    padding-bottom: 30px;
  }

  p {
    padding-bottom: 25px;
  }
}
</style>
