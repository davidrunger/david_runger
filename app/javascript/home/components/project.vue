<template lang='pug'>
el-card.box-card.mt2
  .project.py1.px3
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
