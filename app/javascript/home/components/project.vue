<template lang='pug'>
article.bg-white.bg-lighten-4.py2.px3
  h2.h2.center.mb1
    slot(name='title')
  .center.gray.mb1
    slot(name='technologies')
  .center.mb2
    slot(name='links')

  .mb3.center
    slot(name='image')

  slot(name='overview')

  h3.h3.bold.mb1(v-if='this.$slots["tech-list"]') Tech
  slot(name='tech-list')
</template>

<style lang='scss' scoped>
article {
  box-shadow: rgba(101, 121, 128, 0.51) 2px 2px 2px;
}

img {
  box-shadow: #c0c0c0 2px 2px 10px 0;
  border-radius: 3px;
  max-height: 300px;
  max-width: 90%;
}

p,
ul {
  line-height: 20px;
  margin: 15px auto;
}

ul {
  list-style: initial;

  li {
    margin-left: 20px;
  }
}
</style>
